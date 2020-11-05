# frozen_string_literal: true

module QA
  module EE
    module Page
      module Group
        module Iteration
          class New < QA::Page::Base
            view 'ee/app/assets/javascripts/iterations/components/iteration_form.vue' do
              element :iteration_description_field
              element :iteration_due_date_field
              element :iteration_start_date_field
              element :iteration_title_field, required: true
              element :save_iteration_button
            end

            def click_create_iteration_button
              click_element(:save_iteration_button, EE::Page::Group::Iteration::Show)
            end

            def fill_description(description)
              fill_element(:iteration_description_field, description)
            end

            def fill_due_date(due_date)
              fill_element(:iteration_due_date_field, due_date)
            end

            def fill_start_date(start_date)
              fill_element(:iteration_start_date_field, start_date)
            end

            def fill_title(title)
              fill_element(:iteration_title_field, title)
            end
          end
        end
      end
    end
  end
end
