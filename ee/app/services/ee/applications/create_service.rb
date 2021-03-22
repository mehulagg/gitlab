# frozen_string_literal: true

module EE
  module Applications
    module CreateService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(request)
        super.tap do |application|
          entity = application.owner || current_user
          audit_event_service(entity, request.remote_ip).for_user(full_path: application.name, entity_id: application.id).security_event
        end
      end

      def audit_event_service(entity, ip_address)
        ::AuditEventService.new(current_user,
                                entity,
                                action: :custom,
                                custom_message: 'OAuth application added',
                                ip_address: ip_address)
      end
    end
  end
end
