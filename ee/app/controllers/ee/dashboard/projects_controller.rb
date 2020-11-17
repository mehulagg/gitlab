# frozen_string_literal: true

module EE
  module Dashboard
    module ProjectsController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        before_action :check_adjourned_deletion_listing_availability, only: [:removed]
      end

      # rubocop:disable Gitlab/ModuleWithInstanceVariables
      def removed
        @projects = load_projects(params.merge(aimed_for_deletion: true))

        respond_to do |format|
          format.html
          format.json do
            render json: {
              html: view_to_html_string("dashboard/projects/_projects", projects: @projects)
            }
          end
        end
      end
      # rubocop:enable Gitlab/ModuleWithInstanceVariables

      private

      override :preload_associations
      def preload_associations(projects)
        super.with_compliance_framework_settings
             .with_group_saml_provider
      end

      override :load_projects
      def load_projects(finder_params)
        @removed_projects_count = ::ProjectsFinder.new(params: { aimed_for_deletion: true }, current_user: current_user).execute # rubocop:disable Gitlab/ModuleWithInstanceVariables

        super
      end

      def check_adjourned_deletion_listing_availability
        return render_404 unless can?(current_user, :list_removable_projects)
      end
    end
  end
end
