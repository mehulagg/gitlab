# frozen_string_literal: true

module QA
  module Page
    module Project
      module Operations
        module Metrics
          class Show < Page::Base
            EXPECTED_TITLE = 'Memory Usage (Total)'
            LOADING_MESSAGE = 'Waiting for performance data'

            view 'app/assets/javascripts/monitoring/components/dashboard.vue' do
              element :prometheus_graphs
            end

            view 'app/assets/javascripts/monitoring/components/dashboard_header.vue' do
              element :dashboards_filter_dropdown
              element :environments_dropdown
              element :edit_dashboard_button
              element :range_picker_dropdown
            end

            view 'app/assets/javascripts/monitoring/components/duplicate_dashboard_form.vue' do
              element :duplicate_dashboard_filename_field
            end

            view 'app/assets/javascripts/monitoring/components/dashboard_panel.vue' do
              element :prometheus_graph_widgets
              element :prometheus_widgets_dropdown
              element :alert_widget_menu_item
              element :generate_chart_link_menu_item
            end

            view 'app/assets/javascripts/vue_shared/components/date_time_picker/date_time_picker.vue' do
              element :quick_range_item
            end

            def wait_for_metrics
              wait_for_data
              return if has_metrics?

              wait_until(max_duration: 180) do
                wait_for_data
                has_metrics?
              end
            end

            def has_metrics?
              within_element :prometheus_graphs do
                has_text?(EXPECTED_TITLE)
              end
            end

            def has_edit_dashboard_enabled?
              within_element :prometheus_graphs do
                has_element? :edit_dashboard_button
              end
            end

            def duplicate_dashboard(save_as = 'test_duplication.yml', commit_option = 'Commit to master branch')
              click_element :dashboards_filter_dropdown
              click_on 'Duplicate dashboard'
              fill_element :duplicate_dashboard_filename_field, save_as
              choose commit_option
              within('.modal-content') { click_button(class: 'btn-success') }
            end

            def filter_environment(environment = 'production')
              click_element :environments_dropdown

              within_element :environments_dropdown do
                click_link_with_text environment
              end
            end

            def show_last(range = '8 hours')
              all_elements(:range_picker_dropdown, minimum: 1).first.click
              click_element :quick_range_item, text: range
            end

            def copy_link_to_first_chart
              all_elements(:prometheus_widgets_dropdown, minimum: 1).first.click
              find_element(:generate_chart_link_menu_item)['data-clipboard-text']
            end

            def has_custom_metric?(metric)
              within_element :prometheus_graphs do
                has_text?(metric)
              end
            end

            private

            def wait_for_data
              wait_until(reload: false) { !has_text?(LOADING_MESSAGE) } if has_text?(LOADING_MESSAGE)
            end
          end
        end
      end
    end
  end
end

QA::Page::Project::Operations::Metrics::Show.prepend_if_ee('QA::EE::Page::Project::Operations::Metrics::Show')
