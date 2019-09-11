# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Issue
          module Show
            def self.prepended(page)
              page.module_eval do
                view 'ee/app/assets/javascripts/related_issues/components/related_issues_block.vue' do
                  element :related_issues_loading_icon
                end

                view 'ee/app/assets/javascripts/sidebar/components/weight/weight.vue' do
                  element :weight_label_value
                end
              end
            end

            def wait_for_related_issues_to_load
              wait(reload: false) do
                has_no_element?(:related_issues_loading_icon)
              end
            end

            def weight_label_value
              find_element(:weight_label_value)
            end
          end
        end
      end
    end
  end
end
