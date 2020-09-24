# frozen_string_literal: true

module EE
  module Gitlab
    module GitAccessDesign
      extend ::Gitlab::Utils::Override

      private

      override :check_protocol!
      def check_protocol!
        return if geo?

        super
      end

      override :check_can_create_design!
      def check_can_create_design!
        return if geo?

        super
      end
    end
  end
end
