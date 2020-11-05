# frozen_string_literal: true

module QA
  module EE
    module Page
      module Admin
        class License < QA::Page::Base
          view 'ee/app/views/admin/licenses/missing.html.haml' do
            element :missing_license
          end

          view 'ee/app/views/admin/licenses/show.html.haml' do
            element :license_upload_link
          end

          view 'ee/app/views/admin/licenses/_info.html.haml' do
            element :remove_license_link
          end

          view 'ee/app/views/admin/licenses/new.html.haml' do
            element :license_type, 'radio_button_tag :license_type' # rubocop:disable QA/ElementWithPattern
            element :license_type_placeholder, 'Enter license key' # rubocop:disable QA/ElementWithPattern
            element :license_key_field, 'text_area :data' # rubocop:disable QA/ElementWithPattern
            element :license_key_placeholder, 'label :data, "License key"' # rubocop:disable QA/ElementWithPattern
            element :license_upload_button, "submit 'Upload License'" # rubocop:disable QA/ElementWithPattern
          end

          def license?
            has_element?(:remove_license_link) || !has_element?(:missing_license)
          end

          def add_new_license(key)
            raise 'License key empty!' if key.to_s.empty?

            click_link 'Upload New License'
            choose 'Enter license key'
            fill_in 'License key', with: key
            check 'accept_eula'
            click_button 'Upload License'
          end
        end
      end
    end
  end
end
