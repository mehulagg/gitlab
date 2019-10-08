# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Issue
          module Board
            class Show < QA::Page::Base
              view 'app/assets/javascripts/boards/components/board_card.vue' do
                element :board_card
              end

              view 'app/assets/javascripts/boards/components/board_form.vue' do
                element :board_name_field
              end

              view 'app/assets/javascripts/boards/components/board_list.vue' do
                element :board_list_cards_area
              end

              view 'app/assets/javascripts/boards/components/boards_selector.vue' do
                element :boards_dropdown
              end

              view 'app/assets/javascripts/vue_shared/components/deprecated_modal.vue' do
                element :save_changes_button
              end

              view 'app/views/shared/boards/_show.html.haml' do
                element :boards_list
              end

              view 'app/views/shared/boards/components/_board.html.haml' do
                element :board_list
                element :board_list_header
              end

              view 'ee/app/assets/javascripts/boards/components/board_scope.vue' do
                element :board_scope_modal
              end

              view 'ee/app/assets/javascripts/boards/config_toggle.js' do
                element :boards_config_button
              end

              view 'ee/app/assets/javascripts/boards/toggle_focus.js' do
                element :focus_mode_button
              end

              # The `focused_board` method does not use `find_element` with an element defined
              # with the attribute `data-qa-selector` since such element is not unique when the
              # `is-focused` class is not set, and it was not possible to find a better solution.
              def focused_board
                find('.issue-boards-content.js-focus-mode-board.is-focused')
              end

              def board_scope_modal
                find_element(:board_scope_modal)
              end

              def boards_dropdown
                find_element(:boards_dropdown)
              end

              def boards_list_cards_area_with_index(index)
                wait_boards_list_finish_loading do
                  within_element_by_index(:board_list, index) do
                    find_element(:board_list_cards_area)
                  end
                end
              end

              def boards_list_header_with_index(index)
                wait_boards_list_finish_loading do
                  within_element_by_index(:board_list, index) do
                    find_element(:board_list_header)
                  end
                end
              end

              def card_of_list_with_index(index)
                wait_boards_list_finish_loading do
                  within_element_by_index(:board_list, index) do
                    find_element(:board_card)
                  end
                end
              end

              def click_boards_config_button
                click_element(:boards_config_button)
              end

              def click_focus_mode_button
                click_element(:focus_mode_button)
              end

              def has_modal_board_name_field?
                has_element?(:board_name_field, wait: 1)
              end

              def set_name(name)
                find_element(:board_name_field).set(name)
                click_element(:save_changes_button)
              end

              private

              def wait_boards_list_finish_loading
                within_element(:boards_list) do
                  wait(reload: false, max: 5, interval: 1) do
                    finished_loading?
                    yield
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
