# frozen_string_literal: true

module EE
  module Projects
    module JobsController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        before_action :authorize_web_ide_terminal_enabled!, only: [:valid_config, :create_webide_terminal]
      end

      def valid_config
        result = CiCd::WebIdeConfigValidatorService.new(project, current_user, params).execute

        if result[:status] == :success
          head :ok
        else
          respond_422
        end
      end

      def create_webide_terminal
        return respond_422 unless project.repository.branch_exists?(params[:branch])

        pipeline = ::Ci::CreatePipelineService.new(project,
                                                    current_user,
                                                    ref: params[:branch])
                                               .execute(:webide)

        current_build = pipeline.builds.last

        if current_build
          render_build(current_build)
        else
          render status: :bad_request, json: pipeline.errors.full_messages
        end
      end

      private

      def authorize_web_ide_terminal_enabled!
        return render_403 unless can?(current_user, :web_ide_terminal_enabled, project)
      end

      override :project_builds
      def project_builds
        project.builds.without_webide
      end
    end
  end
end
