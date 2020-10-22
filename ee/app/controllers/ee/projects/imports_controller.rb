# frozen_string_literal: true

module EE
  module Projects
    module ImportsController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      private

      override :import_params_attributes
      def import_params_attributes
        super + [:mirror]
      end

      override :import_params
      def import_params
        super.merge(mirror_user_id: current_user&.id)
      end
    end
  end
end
