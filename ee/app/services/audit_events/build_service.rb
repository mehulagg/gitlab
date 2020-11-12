# frozen_string_literal: true

module AuditEvents
  class BuildService
    def initialize(author:, scope:, target:, ip_address:, message:)
      @author = author
      @scope = scope
      @target = target
      @ip_address = ip_address
      @message = message
    end

    def execute
      AuditEvent.new(payload)
    end

    private

    def payload
      if License.feature_available?(:admin_audit_log)
        base_payload.merge(
          details: base_details_payload.merge(
            ip_address: @ip_address,
            entity_path: @scope.full_path
          ),
          ip_address: ip_address
        )
      else
        base_payload.merge(details: base_details_payload)
      end
    end

    def base_payload
      {
        author_id: @author.id,
        author_name: @author.name,
        entity_id: @scope.id,
        entity_type: @scope.class.name,
        created_at: DateTime.current
      }
    end

    def base_details_payload
      {
        author_name: @author.name,
        target_id: @target.id,
        target_type: @target.class.name,
        target_details: @target.name,
        custom_message: @message
      }
    end

    def ip_address
      @ip_address.presence || @author.current_sign_in_ip
    end
  end
end
