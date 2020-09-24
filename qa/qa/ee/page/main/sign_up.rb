# frozen_string_literal: true

module QA
  module EE
    module Page
      module Main
        module SignUp
          extend QA::Page::PageConcern

          def self.included(base)
            super

            base.view 'ee/app/views/registrations/welcome/_button.html.haml' do
              element :get_started_button
            end
          end
        end
      end
    end
  end
end
