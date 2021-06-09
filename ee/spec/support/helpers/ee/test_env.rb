# frozen_string_literal: true

module EE
  module TestEnv
    extend ::Gitlab::Utils::Override

    override :setup_methods
    def setup_methods
      (super + [:setup_indexer]).freeze
    end

    override :post_init
    def post_init
      super

      Settings.elasticsearch['indexer_path'] = indexer_bin_path
    end

    def setup_indexer
      component_timed_setup(
        'GitLab Elasticsearch Indexer',
        install_dir: indexer_path,
        version: indexer_version,
        task: "gitlab:indexer:install",
        task_args: [indexer_path, indexer_url].compact
      )
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
