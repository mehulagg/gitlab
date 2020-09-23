# frozen_string_literal: true

module EE
  module DesignManagement
    module SaveDesignsService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        super.tap do |response|
          # Create a Geo event so changes will be replicated to secondary node(s)
          repository.log_geo_updated_event if response[:status] == :success
        end
      end
    end
  end
end
