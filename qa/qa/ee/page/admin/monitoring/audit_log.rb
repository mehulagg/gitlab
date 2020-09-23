# frozen_string_literal: true

module QA
  module EE
    module Page
      module Admin
        module Monitoring
          class AuditLog < QA::Page::Base
            view 'ee/app/views/admin/audit_logs/index.html.haml' do
              element :admin_audit_log_table
            end

            def has_audit_log_table_with_text?(text)
              # Sometimes the audit logs are not displayed in the UI
              # right away so a refresh may be needed.
              # https://gitlab.com/gitlab-org/gitlab/issues/119203
              # TODO: https://gitlab.com/gitlab-org/gitlab/issues/195424
              wait_until(reload: true) do
                has_element?(:admin_audit_log_table, text: text)
              end
            end
          end
        end
      end
    end
  end
end
