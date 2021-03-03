# frozen_string_literal: true

namespace :gitlab do
  namespace :indexer do
    desc "GitLab | Indexer | Install or upgrade gitlab-elasticsearch-indexer"
    task :install, [:dir, :repo] => :gitlab_environment do |t, args|
      unless args.dir.present?
        abort %(Please specify the directory where you want to install the indexer
Usage: rake "gitlab:indexer:install[/installation/dir,repo]")
      end

      args.with_defaults(repo: 'https://gitlab.com/gitlab-org/gitlab-elasticsearch-indexer.git')
      version = Gitlab::Elastic::Indexer.indexer_version
      make = Gitlab::Utils.which('gmake') || Gitlab::Utils.which('make')

      abort "Couldn't find a 'make' binary" unless make

      checkout_or_clone_version(version: version, repo: args.repo, target_dir: args.dir, clone_opts: %w[--depth 1])

      Dir.chdir(args.dir) { run_command!([make, 'build']) }
    end
  end
end
