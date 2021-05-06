# frozen_string_literal: true

load File.expand_path('../../../../../lib/tasks/gitlab/helpers.rake', __dir__)
load File.expand_path('../../../../lib/tasks/gitlab/indexer.rake', __dir__)

require_relative '../../../../lib/gitlab/elastic/indexer' unless defined?(Gitlab::Elastic::Indexer)

module EE
  module TestEnv
    def init(*args, &blk)
      super

      setup_indexer
    end

    def setup_indexer
      indexer_args = [indexer_path, indexer_url].compact

      component_timed_setup(
        'GitLab Elasticsearch Indexer',
        install_dir: indexer_path,
        version: indexer_version,
        task: "gitlab:indexer:install",
        task_args: indexer_args
      )

      Settings.elasticsearch['indexer_path'] = indexer_bin_path
    end

    def indexer_path
      @indexer_path ||= File.join('tmp', 'tests', 'gitlab-elasticsearch-indexer')
    end

    def indexer_bin_path
      @indexer_bin_path ||= File.join(indexer_path, 'bin', 'gitlab-elasticsearch-indexer')
    end

    def indexer_version
      @indexer_version ||= ::Gitlab::Elastic::Indexer.indexer_version
    end

    def indexer_url
      ENV.fetch('GITLAB_ELASTICSEARCH_INDEXER_URL', nil)
    end

    private

    def test_dirs
      @ee_test_dirs ||= super + ['gitlab-elasticsearch-indexer']
    end
  end
end
