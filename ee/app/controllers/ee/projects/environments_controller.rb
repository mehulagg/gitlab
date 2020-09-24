# frozen_string_literal: true

module EE
  module Projects
    module EnvironmentsController
      extend ActiveSupport::Concern

      prepended do
        before_action :authorize_create_environment_terminal!, only: [:terminal]
      end

      private

      def authorize_create_environment_terminal!
        return render_404 unless can?(current_user, :create_environment_terminal, environment)
      end
    end
  end
end
