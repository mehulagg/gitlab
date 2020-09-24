# frozen_string_literal: true

module QA
  module EE
    module Page
      module Main
        module Menu
          extend QA::Page::PageConcern

          def self.included(base)
            super

            base.view 'ee/app/views/dashboard/_nav_link_list.html.haml' do
              element :environment_link
              element :operations_link
              element :security_link
            end
          end
        end
      end
    end
  end
end
