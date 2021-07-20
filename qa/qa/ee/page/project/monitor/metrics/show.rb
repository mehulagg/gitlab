# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Monitor
          module Metrics
            module Show
              extend QA::Page::PageConcern

              EXPECTED_LABEL = 'Total (GB)'

              def self.prepended(base)
                super

                base.class_eval do
                  view 'app/assets/javascripts/monitoring/components/alert_widget_form.vue' do
                    element :alert_query_dropdown
                    element :alert_query_option
                    element :alert_threshold_field
                  end
                end
              end

              def wait_for_alert(operator = '>', threshold = 0)
                wait_until(reload: false) { has_alert?(operator, threshold) }
              end

              def has_alert?(operator = '>', threshold = 0)
                within_element :prometheus_graphs do
                  has_text?([EXPECTED_LABEL, operator, threshold].join(' '))
                end
              end

              def write_first_alert(operator = '>', threshold = 0)
                open_first_alert_modal
                click_on operator
                fill_element :alert_threshold_field, threshold

                within('.modal-content') { click_button(class: 'btn-success') }
              end

              def delete_first_alert
                open_first_alert_modal

                within('.modal-content') { click_button(class: 'btn-danger') }
                wait_for_requests
              end

              def open_first_alert_modal
                all_elements(:prometheus_widgets_dropdown, minimum: 1).first.click
                click_element :alert_widget_menu_item

                click_element :alert_query_dropdown unless has_element?(:alert_query_option, wait: 3)
                all_elements(:alert_query_option, minimum: 1).first.click
              end
            end
          end
        end
      end
    end
  end
end
