# frozen_string_literal: true

module QA
  module EE
    module Page
      module Admin
        module Geo
          module Nodes
            class Show < QA::Page::Base
              view 'ee/app/views/admin/geo/nodes/index.html.haml' do
                element :new_node_link
              end

              view 'ee/app/assets/javascripts/geo_nodes/components/geo_node_actions.vue' do
                element :geo_node_edit_button
              end

              def new_node!
                click_element :new_node_link
              end

              def click_edit_secondary_node_link
                all_elements(:geo_node_edit_button, count: 2).last.click
              end
            end
          end
        end
      end
    end
  end
end
