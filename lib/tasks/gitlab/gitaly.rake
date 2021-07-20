# frozen_string_literal: true

namespace :gitlab do
  namespace :gitaly do
    desc 'Installs gitaly for running tests within gitlab-development-kit'
    task :test_install, [:dir, :storage_path, :repo] => :gitlab_environment do |t, args|
      if Rails.env.test? && ENV['GDK_GITALY']
        version = Gitlab::GitalyClient.expected_server_version
        checkout_or_clone_version(version: version, repo: ENV['GDK_GITALY'], target_dir: args.dir, clone_opts: %w[--depth 1])

        build_dir = File.join(ENV['GDK_GITALY'], '_build')
        FileUtils.cp_r(build_dir, args.dir) if Dir.exist?(build_dir)
      else
        Rake::Task["gitlab:gitaly:install"].invoke(*args)
      end
    end

    desc 'GitLab | Gitaly | Install or upgrade gitaly'
    task :install, [:dir, :storage_path, :repo] => :gitlab_environment do |t, args|
      warn_user_is_not_gitlab

      unless args.dir.present? && args.storage_path.present?
        abort %(Please specify the directory where you want to install gitaly and the path for the default storage
Usage: rake "gitlab:gitaly:install[/installation/dir,/storage/path]")
      end

      args.with_defaults(repo: 'https://gitlab.com/gitlab-org/gitaly.git')

      version = Gitlab::GitalyClient.expected_server_version

      checkout_or_clone_version(version: version, repo: args.repo, target_dir: args.dir, clone_opts: %w[--depth 1])

      storage_paths = { 'default' => args.storage_path }
      Gitlab::SetupHelper::Gitaly.create_configuration(args.dir, storage_paths)

      # In CI we run scripts/gitaly-test-build
      next if ENV['CI'].present?

      Dir.chdir(args.dir) do
        Bundler.with_original_env do
          env = { "RUBYOPT" => nil, "BUNDLE_GEMFILE" => nil }

          if Rails.env.test?
            env["GEM_HOME"] = Bundler.bundle_path.to_s
            env["BUNDLE_DEPLOYMENT"] = 'false'
          end

          Gitlab::Popen.popen([make_cmd], nil, env)
        end
      end
    end

    def make_cmd
      _, status = Gitlab::Popen.popen(%w[which gmake])
      status == 0 ? 'gmake' : 'make'
    end
  end
end
