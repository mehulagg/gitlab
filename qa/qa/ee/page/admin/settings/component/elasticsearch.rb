# frozen_string_literal: true

module QA
  module EE
    module Page
      module Admin
        module Settings
          module Component
            class Elasticsearch < QA::Page::Base
              view 'ee/app/views/admin/application_settings/_elasticsearch_form.html.haml' do
                element :indexing_checkbox
                element :search_checkbox
                element :url_field
                element :submit_button
              end

              def check_indexing
                check_element(:indexing_checkbox)
              end

              def check_search
                check_element(:search_checkbox)
              end

              def enter_link(link)
                fill_element(:url_field, link)
              end

              def click_submit
                click_element(:submit_button)
              end
            end
          end
        end
      end
    end
  end
end
