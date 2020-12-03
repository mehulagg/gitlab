# frozen_string_literal: true

module ComplianceManagement
  module Frameworks
    module BaseService
      private

      def permitted?
        can? current_user, :manage_compliance_framework, framework
      end
    end
  end
end
