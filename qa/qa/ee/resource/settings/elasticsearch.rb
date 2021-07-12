# frozen_string_literal: true

module QA
  module EE
    module Resource
      module Settings
        class Elasticsearch < QA::Resource::Base
          attr_accessor :es_enabled
          attr_accessor :es_indexing
          attr_accessor :es_url

          def initialize
            @es_enabled = true
            @es_indexing = true
            @es_url = QA::Runtime::Env.elasticsearch_url
          end

          def fabricate!
            QA::Page::Main::Menu.perform(&:go_to_admin_area)
            QA::Page::Admin::Menu.perform(&:go_to_advanced_search)
            QA::EE::Page::Admin::Settings::Component::Elasticsearch.perform do |es|
              if es.has_no_indexing_checkbox_element?
                es.click_expand_advanced_search
              end

              es.check_indexing if @es_indexing
              es.check_search if @es_enabled
              es.enter_link(@es_url)
              es.click_submit
            end

            sleep(180)
            # wait for the change to propagate before inserting records or else
            # Gitlab::CurrentSettings.elasticsearch_indexing and
            # Elastic::ApplicationVersionedSearch::searchable? will be false
            # this sleep can be removed after we're able to query logs via the API
            # as per this issue https://gitlab.com/gitlab-org/quality/team-tasks/issues/395
          end

          def fabricate_via_api!
            @es_enabled ? api_put : resource_web_url(api_get)
            sleep(180)
          end

          def resource_web_url(resource)
            super
          rescue ResourceURLMissingError
            # this particular resource does not expose a web_url property
          end

          def api_get_path
            "/application/settings"
          end

          def api_put_path
            "/application/settings"
          end

          def api_put_body
            {
              elasticsearch_search: @es_enabled,
              elasticsearch_indexing: @es_indexing,
              elasticsearch_url: @es_url
            }
          end
        end
      end
    end
  end
end
