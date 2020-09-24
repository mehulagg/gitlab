# frozen_string_literal: true

module QA
  module EE
    module Page
      module Admin
        module Geo
          module Nodes
            class New < QA::Page::Base
              view 'ee/app/assets/javascripts/geo_node_form/components/geo_node_form_core.vue' do
                element :node_name_field
                element :node_url_field
              end

              view 'ee/app/assets/javascripts/geo_node_form/components/geo_node_form.vue' do
                element :add_node_button
              end

              def set_node_name(name)
                fill_element :node_name_field, name
              end

              def set_node_address(address)
                fill_element :node_url_field, address
              end

              def add_node!
                click_element :add_node_button
              end
            end
          end
        end
      end
    end
  end
end
