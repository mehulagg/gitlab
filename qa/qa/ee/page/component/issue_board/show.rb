# frozen_string_literal: true

module QA
  module EE
    module Page
      module Component
        module IssueBoard
          module Show
            extend QA::Page::PageConcern

            def self.prepended(base)
              super
              base.class_eval do
                view 'ee/app/assets/javascripts/boards/components/board_scope.vue' do
                  element :board_scope_modal
                end

                view 'ee/app/assets/javascripts/boards/config_toggle.js' do
                  element :boards_config_button
                end
              end
            end

            def board_scope_modal
              find_element(:board_scope_modal)
            end

            def click_boards_config_button
              click_element(:boards_config_button)
            end
          end
        end
      end
    end
  end
end
