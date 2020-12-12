# frozen_string_literal: true

module QA
  module EE
    module Page
      module Admin
        module Settings
          extend QA::Page::PageConcern

          def self.prepended(base)
            super

            base.class_eval do
              view 'ee/app/views/admin/application_settings/_maintenance_mode_settings_form.html.haml' do
                element :maintenance_mode_content
              end
            end
          end

          def expand_maintenance_mode(&block)
            expand_content(:maintenance_mode_content) do
              Component::MaintenanceMode.perform(&block)
            end
          end
        end
      end
    end
  end
end
