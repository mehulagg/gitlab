# frozen_string_literal: true

module QA
  module EE
    module Page
      module Admin
        module Geo
          module Nodes
            class Edit < QA::Page::Base
              view 'ee/app/assets/javascripts/geo_node_form/components/geo_node_form_selective_sync.vue' do
                element :geo_object_storage_replication_checkbox
              end

              def enable_object_storage_geo_replication
                check_element(:geo_object_storage_replication_checkbox)
              end
            end
          end
        end
      end
    end
  end
end