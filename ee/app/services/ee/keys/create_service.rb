module EE
  module Keys
    module CreateService
      def initialize(user, params)
        super(user, params)

        @ip_address = @params.delete(:ip_address)
      end

      def execute
        super.tap do |key|
          log_audit_event(key)
        end
      end

      def log_audit_event(key)
        ::AuditEventService.new(@user,
                                @user,
                                action: :custom,
                                custom_message: 'Added SSH key',
                                ip_address: @ip_address)
            .for_user(key.title).security_event
      end
    end
  end
end
