# frozen_string_literal: true

require 'stringio'

module GDK
  module Diagnostic
    def self.all
      constants.grep(/^Diagnose/).map do |const|
        const_get(const).new
      end
    end

    class Base
      TITLE = 'Diagnostic name'

      def diagnose
        raise NotImplementedError
      end

      def success?
        raise NotImplementedError
      end

      def message
        <<~MESSAGE

          #{self.class::TITLE}
          #{'-' * 80}
          #{detail}
        MESSAGE
      end

      def detail
        ''
      end

      private

      def config
        @config ||= GDK::Config.new
      end
    end

    class DiagnoseDependencies < Base
      TITLE = 'GDK Dependencies'

      def diagnose
        @checker = Dependencies::Checker.new
        @checker.check_all
      end

      def success?
        @checker.error_messages.empty?
      end

      def detail
        messages = @checker.error_messages.join("\n").chomp
        return if messages.empty?

        <<~MESSAGE
          #{messages}

          For details on how to install, please visit:

          https://gitlab.com/gitlab-org/gitlab-development-kit/blob/master/doc/prepare.md#platform-specific-setup
        MESSAGE
      end
    end

    class DiagnoseVersion < Base
      TITLE = 'GDK Version'

      def diagnose
        @gdk_master = `git show-ref refs/remotes/origin/master -s --abbrev`
        @head = `git rev-parse --short HEAD`
      end

      def success?
        @head == @gdk_master
      end

      def detail
        <<~MESSAGE
          An update for GDK is available. Unless you are developing on GDK itself,
          consider updating GDK with `gdk update`.
        MESSAGE
      end
    end

    class DiagnoseStatus < Base
      TITLE = 'GDK Status'

      def diagnose
        shell = Shellout.new('gdk status')
        shell.run
        status = shell.read_stdout

        @down_services = status.split("\n").select { |svc| svc.start_with?('down') }
      end

      def success?
        @down_services.empty?
      end

      def detail
        <<~MESSAGE
          The following services are not running:

          #{@down_services.join("\n")}
        MESSAGE
      end
    end

    class DiagnosePendingMigrations < Base
      TITLE = 'Database Migrations'

      def diagnose
        @shellout = Shellout.new(%w[bundle exec rails db:abort_if_pending_migrations], chdir: 'gitlab')
        @shellout.run
      end

      def success?
        @shellout.success?
      end

      def detail
        <<~MESSAGE
          There are pending database migrations.
          To update your database, run `cd gitlab && bundle exec rails db:migrate`.
        MESSAGE
      end
    end

    class DiagnoseConfiguration < Base
      TITLE = 'GDK Configuration'

      def diagnose
        out = StringIO.new
        err = StringIO.new

        GDK::Command::DiffConfig.new.run(stdout: out, stderr: err)

        out.close
        err.close

        @config_diff = out.string.chomp
      end

      def success?
        @config_diff.empty?
      end

      def detail
        <<~MESSAGE
          Please review the following diff or consider `gdk reconfigure`.

          #{@config_diff}
        MESSAGE
      end
    end

    class DiagnoseGeo < Base
      TITLE = 'Geo'

      def diagnose
        @success = true

        if database_geo_yml_exists? && !geo_enabled?
          @success = false
        end
      end

      def success?
        @success
      end

      def detail
        <<~MESSAGE
          #{database_geo_yml_file} exists but
          geo.enabled is not set to true in your gdk.yml.

          Either update your gdk.yml to set geo.enabled to true or remove
          #{database_geo_yml_file}

          #{geo_howto_url}
        MESSAGE
      end

      private

      def geo_enabled?
        config.geo.enabled
      end

      def database_geo_yml_file
        config.gdk_root.join('gitlab', 'config', 'database_geo.yml').expand_path.to_s
      end

      def database_geo_yml_exists?
        File.exist?(database_geo_yml_file)
      end

      def geo_howto_url
        'https://gitlab.com/gitlab-org/gitlab-development-kit/blob/master/doc/howto/geo.md'
      end
    end
  end
end
