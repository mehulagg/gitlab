# frozen_string_literal: true

module EE
  module Ci
    module ChangeVariableService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        super.tap do |target_variable|
          if target_variable.valid?
            ::Ci::AuditVariableChangeService.new(
              container: container,
              current_user: current_user,
              params: { action: params[:action], variable: target_variable }
            ).execute
          end
        end
      end
    end
  end
end
