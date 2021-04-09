# frozen_string_literal: true

module EE
  module Registrations
    module WelcomeController
      extend ::Gitlab::Utils::Override

      TRIAL_ONBOARDING_BOARD_NAME = 'GitLab onboarding'

      def trial_getting_started
        project = learn_gitlab_project
        return access_denied! unless current_user.id == project.creator_id

        render locals: { learn_gitlab_project: learn_gitlab_project }
      end

      def trial_onboarding_board
        project = learn_gitlab_project
        return access_denied! unless current_user.id == project.creator_id

        board = project.boards.find_by_name(TRIAL_ONBOARDING_BOARD_NAME)
        path = board ? project_board_path(project, board) : project_boards_path(project)
        redirect_to path
      end

      private

      override :update_params
      def update_params
        clean_params = super

        return clean_params unless ::Gitlab.dev_env_or_com?

        clean_params[:email_opted_in] = '1' if clean_params[:setup_for_company] == 'true'

        if clean_params[:email_opted_in] == '1'
          clean_params[:email_opted_in_ip] = request.remote_ip
          clean_params[:email_opted_in_source_id] = User::EMAIL_OPT_IN_SOURCE_ID_GITLAB_COM
          clean_params[:email_opted_in_at] = Time.zone.now
        end

        clean_params
      end

      override :show_signup_onboarding?
      def show_signup_onboarding?
        !helpers.in_subscription_flow? &&
          !helpers.user_has_memberships? &&
          !helpers.in_oauth_flow? &&
          !helpers.in_trial_flow? &&
          helpers.signup_onboarding_enabled?
      end

      def learn_gitlab_project
        ::Project.find(params[:learn_gitlab_project_id])
      end
    end
  end
end
