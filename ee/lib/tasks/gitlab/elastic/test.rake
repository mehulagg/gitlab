namespace :gitlab do
  namespace :elastic do
    namespace :test do
      desc 'GitLab | Elasticsearch | Test | Measure space taken by ES indices'
      task index_size: :environment do
        puts "===== Size stats for index: #{Project.__elasticsearch__.index_name} ====="
        pp Gitlab::Elastic::Helper.default.index_size.slice(*%w(docs store))
      end

      desc 'GitLab | Elasticsearch | Test | Measure space taken by ES indices, reindex, and measure space taken again'
      task :index_size_change do
        Rake::Task["gitlab:elastic:test:index_size"].invoke

        puts '===== Reindexing, please wait ====='

        silence_stdout do
          Rake::Task["gitlab:elastic:index"].invoke
        end

        # `#invoke` will only ever invoke a rake task once unless it gets reenabled and
        # we can't use `#execute` because the `index_size` task depends on loading the environment
        Rake::Task["gitlab:elastic:test:index_size"].reenable
        Rake::Task["gitlab:elastic:test:index_size"].invoke

        puts 'Done! Please ensure document count is the expected value, otherwise please check indexing is working properly.'
      end
    end
  end
end

def silence_stdout(&_block)
  old_stdout = $stdout.dup
  $stdout.reopen(File::NULL)
  $stdout.sync = true

  yield
ensure
  $stdout.reopen(old_stdout)
  old_stdout.close
end
