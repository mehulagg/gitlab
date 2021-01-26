# frozen_string_literal: true

module QA
  module EE
    module Page
      module Group
        module Iteration
          class Index < QA::Page::Base
            view 'ee/app/assets/javascripts/iterations/components/iterations.vue' do
              element :new_iteration_button
            end

            def click_new_iteration_button
              click_element(:new_iteration_button, EE::Page::Group::Iteration::New)
            end
          end
        end
      end
    end
  end
end
