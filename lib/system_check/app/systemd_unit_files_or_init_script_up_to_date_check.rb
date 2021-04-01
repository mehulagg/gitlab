# frozen_string_literal: true

module SystemCheck
  module App
    class SystemdUnitFilesOrInitScriptUpToDateCheck < SystemCheck::BaseCheck
      SCRIPT_PATH = '/etc/init.d/gitlab'
      UNIT_PATHS = [
        '/usr/lib/systemd/system/gitlab-gitaly.service',
        '/usr/lib/systemd/system/gitlab-mailroom.service',
        '/usr/lib/systemd/system/gitlab-puma.service',
        '/usr/lib/systemd/system/gitlab-sidekiq.service',
        '/usr/lib/systemd/system/gitlab.slice',
        '/usr/lib/systemd/system/gitlab.target',
        '/usr/lib/systemd/system/gitlab-workhorse.service'
      ].freeze

      set_name 'Systemd unit files or init script up-to-date?'
      set_skip_reason 'skipped (omnibus-gitlab has neither init script nor systemd units)'

      def skip?
        return true if omnibus_gitlab?

        unless unit_files_exist? || init_file_exists?
          self.skip_reason = "can't check because of previous errors"

          true
        end
      end

      def check?
        unit_files_up_to_date? || init_file_up_to_date?
      end

      def show_error
        try_fixing_it(
          'Install the Service'
        )
        for_more_information(
          see_installation_guide_section('Install the Service')
        )
        fix_and_rerun
      end

      private

      def init_file_exists?
        File.exist?(SCRIPT_PATH)
      end

      def unit_files_exist?
        UNIT_PATHS.all? { |s| File.exist?(s) }
      end

      def init_file_up_to_date?
        recipe_path = Rails.root.join('lib/support/init.d/', 'gitlab')

        recipe_content = File.read(recipe_path)
        script_content = File.read(SCRIPT_PATH)

        recipe_content == script_content
      end

      def unit_files_up_to_date?
        UNIT_PATHS.each do |unit|
          unit_name = File.basename(unit)
          recipe_path = Rails.root.join('lib/support/systemd/', unit_name)

          recipe_content = File.read(recipe_path)
          unit_content = File.read(unit)

          return false unless recipe_content == unit_content
        end

        true
      end
    end
  end
end
