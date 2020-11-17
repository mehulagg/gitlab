# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Settings
          module ProtectedTags
            extend QA::Page::PageConcern

            def self.prepended(base)
              super

              base.class_eval do
                view 'ee/app/views/projects/protected_tags/ee/_create_protected_tag.html.haml' do
                  element :access_levels_content
                  element :access_levels_dropdown
                end
              end
            end
          end
        end
      end
    end
  end
end
