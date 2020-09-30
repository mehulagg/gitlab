# frozen_string_literal: true

module EE
  module Applications
    module CreateService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(request)
        super.tap do |application|
          audit_event_service(request.remote_ip).for_user(full_path: application.name, entity_id: application.id).security_event
        end
      end

      def audit_event_service(ip_address)
        ::AuditEventService.new(current_user,
                                current_user,
                                action: :custom,
                                custom_message: 'OAuth access granted',
                                ip_address: ip_address)
      end
    end
  end
end
