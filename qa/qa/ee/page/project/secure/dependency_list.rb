# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Secure
          class DependencyList < QA::Page::Base
            view 'ee/app/assets/javascripts/dependencies/components/dependencies_table.vue' do
              element :dependencies_table_content
            end
            def has_dependency_count_of?(expected)
              within_element(:dependencies_table_content) do
                # expected rows plus header row
                header_row = 1
                all('tr').count.equal?(expected + header_row)
              end
            end
          end
        end
      end
    end
  end
end
