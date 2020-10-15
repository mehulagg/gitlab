# frozen_string_literal: true

module EE
  module API
    module PersonalAccessTokens
      extend ActiveSupport::Concern

      prepended do
        helpers do
          extend ::Gitlab::Utils::Override

          override :log_personal_access_token_created_audit_event
          def log_personal_access_token_created_audit_event(token)
            message = "Created personal access token with id #{token.id}"
            EE::AuditEvents::PersonalAccessTokenAuditEventService.new(current_user, request.ip, message)
              .for_user(full_path: token.user.username, entity_id: token.user.id).security_event
          end

          override :log_personal_access_token_deleted_audit_event
          def log_personal_access_token_deleted_audit_event(token)
            message = "Deleted personal access token with id #{token.id}"
            EE::AuditEvents::PersonalAccessTokenAuditEventService.new(current_user, request.ip, message)
              .for_user(full_path: token.user.username, entity_id: token.user.id).security_event
          end
        end
      end
    end
  end
end
