# frozen_string_literal: true

module EE
  module ResourceAccessTokens
    module CreateService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        super.tap do |response|
          token = response.payload[:access_token]

          if response.success?
            audit_token_created(token)
          else
            audit_token_failed(current_user, response.message)
          end
        end
      end

      private

      def audit_token_created(token)
        audit_context = {
          name: 'resource_acess_token_created',
          author: current_user,
          scope: resource,
          target: token,
          ip_address: current_user.current_sign_in_ip,
          message: "Created #{resource_type} access token with token_id: #{token.id} with scopes: #{token.scopes}"
        }

        ::Gitlab::Audit::Auditor.audit(audit_context)
      end

      def audit_token_failed(user, message)
        audit_context = {
          name: 'resource_acess_token_failed',
          author: current_user,
          scope: resource,
          target: user,
          ip_address: current_user.current_sign_in_ip,
          message: "Attempted to create #{resource_type} access token but failed with message: #{message}"
        }

        ::Gitlab::Audit::Auditor.audit(audit_context)
      end
    end
  end
end
