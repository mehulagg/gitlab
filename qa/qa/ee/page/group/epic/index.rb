# frozen_string_literal: true

module QA
  module EE
    module Page
      module Group
        module Epic
          class Index < QA::Page::Base
            view 'ee/app/views/groups/epics/_epic.html.haml' do
              element :epic_title_text
            end

            view 'ee/app/views/groups/epics/index.html.haml' do
              element :new_epic_button
            end

            def click_new_epic
              click_element :new_epic_button, EE::Page::Group::Epic::New
            end

            def click_first_epic(page = nil)
              all_elements(:epic_title_text, minimum: 1).first.click
              page.validate_elements_present! if page
            end

            def has_epic_title?(title)
              wait_until do
                has_element?(:epic_title_text, text: title)
              end
            end
          end
        end
      end
    end
  end
end
