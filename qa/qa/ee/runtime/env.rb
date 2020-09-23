# frozen_string_literal: true

# Prepended onto ::QA::Runtime::Env
module QA
  module EE
    module Runtime
      module Env
        def geo_max_db_replication_time
          ENV['GEO_MAX_DB_REPLICATION_TIME']
        end

        def geo_max_file_replication_time
          ENV['GEO_MAX_FILE_REPLICATION_TIME']
        end

        def simple_saml_hostname
          ENV['SIMPLE_SAML_HOSTNAME']
        end

        def simple_saml_fingerprint
          ENV['SIMPLE_SAML_FINGERPRINT']
        end

        def elasticsearch_url
          ENV.fetch('ELASTIC_URL', 'http://elastic68:9200')
        end
      end
    end
  end
end
