# frozen_string_literal: true

module QA
  module Page
    module Project
      module Registry
        class Show < QA::Page::Base
          view 'app/assets/javascripts/registry/explorer/components/list_page/image_list_row.vue' do
            element :registry_information_content
          end

          def has_image_repository?(name, version)
            has_element?(:registry_information_content, text: /#{name}\/*#{version}/)
          end
        end
      end
    end
  end
end
