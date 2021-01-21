# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Settings
          module Main
            extend QA::Page::PageConcern

            def self.prepended(base)
              super

              base.class_eval do
                view 'ee/app/views/projects/_merge_request_approvals_settings.html.haml' do
                  element :merge_request_approvals_settings
                end
              end
            end

            def expand_merge_request_approvals_settings(&block)
              expand_content(:merge_request_approvals_settings) do
                MergeRequestApprovals.perform(&block)
              end
            end
          end
        end
      end
    end
  end
end
