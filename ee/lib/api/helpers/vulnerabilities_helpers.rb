# frozen_string_literal: true

module API
  module Helpers
    module VulnerabilitiesHelpers
      def find_and_authorize_vulnerability!(action)
        find_vulnerability!.tap do |vulnerability|
          authorize_vulnerability!(vulnerability, action)
        end
      end

      def authorize_vulnerability!(vulnerability, action)
        authorize! action, vulnerability.project
      end
    end
  end
end
