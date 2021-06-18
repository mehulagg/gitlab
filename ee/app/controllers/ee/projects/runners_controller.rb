# frozen_string_literal: true

module EE
  module Projects
    module RunnersController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      override :toggle_shared_runners
      def toggle_shared_runners
        if !project.shared_runners_enabled && !current_user.has_required_credit_card_to_enable_shared_runners?(project)
          render json: { error: _('Cannot enable shared runners until you have a valid credit card on file') }, status: :unauthorized
          return
        end

        super
      end
    end
  end
end
