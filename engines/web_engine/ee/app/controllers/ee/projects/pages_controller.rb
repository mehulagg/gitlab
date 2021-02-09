# frozen_string_literal: true

module EE
  module Projects
    module PagesController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      override :project_params_attributes
      def project_params_attributes
        super + project_params_ee
      end

      private

      def project_params_ee
        if can?(current_user, :update_max_pages_size)
          %i[max_pages_size]
        else
          []
        end
      end
    end
  end
end
