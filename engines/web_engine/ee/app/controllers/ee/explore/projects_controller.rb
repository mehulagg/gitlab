# frozen_string_literal: true

module EE
  module Explore
    module ProjectsController
      extend ::Gitlab::Utils::Override

      private

      override :preload_associations
      def preload_associations(projects)
        super.with_compliance_framework_settings
      end

      override :load_project_counts
      def load_project_counts
        @removed_projects_count = ::ProjectsFinder.new(params: { aimed_for_deletion: true }, current_user: current_user).execute # rubocop:disable Gitlab/ModuleWithInstanceVariables

        super
      end
    end
  end
end
