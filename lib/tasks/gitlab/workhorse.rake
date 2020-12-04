namespace :gitlab do
  namespace :workhorse do
    desc "GitLab | Workhorse | Install or upgrade gitlab-workhorse"
    task :install, [:dir, :repo] => :gitlab_environment do |t, args|
      warn_user_is_not_gitlab

      unless args.dir.present?
        abort %(Please specify the directory where you want to install gitlab-workhorse:\n  rake "gitlab:workhorse:install[/home/git/gitlab-workhorse]")
      end

      # Make sure the working directory is empty so users cannot run 'make' in
      # args.dir and install the wrong version. The workhorse-move-notice
      # branch has an almost empty directory that exists for this special
      # purpose.
      args.with_defaults(repo: 'https://gitlab.com/gitlab-org/gitlab-workhorse.git')
      checkout_or_clone_version(version: 'workhorse-move-notice', repo: args.repo, target_dir: args.dir, clone_opts: %w[--depth 1])

      _, status = Gitlab::Popen.popen(%w[which gmake])
      command = %W[#{status == 0 ? 'gmake' : 'make'} -C #{Rails.root.join('workhorse')} install PREFIX=#{File.absolute_path(args.dir)}]

      run_command!(command)

      # 'make install' puts the binaries in #{args.dir}/bin but the init script expects them in args.dir
      FileUtils.mv(Dir["#{args.dir}/bin/*"], args.dir)
    end
  end
end
