# frozen_string_literal: true

module EE
  module Projects
    module ProtectedRefsController
      extend ::Gitlab::Utils::Override

      protected

      override :access_level_attributes
      def access_level_attributes
        super + %i[user_id group_id]
      end
    end
  end
end
