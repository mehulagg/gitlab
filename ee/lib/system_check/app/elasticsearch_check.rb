# frozen_string_literal: true

module SystemCheck
  module App
    class ElasticsearchCheck < SystemCheck::BaseCheck
      set_name 'Elasticsearch version 7.x (6.4 - 6.x deprecated to be removed in 13.8)?'
      set_skip_reason 'skipped (elasticsearch is disabled)'
      set_check_pass -> { "yes (#{self.current_version})" }
      set_check_fail -> { "no (#{self.current_version})" }

      def self.current_version
        @current_version ||= begin
          client = Gitlab::Elastic::Client.build(Gitlab::CurrentSettings.current_application_settings.elasticsearch_config)
          Gitlab::VersionInfo.parse(client.info['version']['number'])
        end
      end

      def skip?
        !Gitlab::CurrentSettings.current_application_settings.elasticsearch_indexing?
      end

      def check?
        case self.class.current_version.major
        when 6
          self.class.current_version.minor >= 4
        when 7
          true
        else
          false
        end
      end

      def show_error
        for_more_information(
          'doc/integration/elasticsearch.md'
        )
      end
    end
  end
end
