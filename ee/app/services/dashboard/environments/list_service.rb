# frozen_string_literal: true

module Dashboard
  module Environments
    class ListService
      def initialize(user)
        @user = user
      end

      def execute
        load_projects(user)
      end

      private

      attr_reader :user

      # rubocop: disable CodeReuse/ActiveRecord
      def load_projects(user)
        projects = ::Dashboard::Projects::ListService
          .new(user, feature: :operations_dashboard)
          .execute(user.ops_dashboard_projects)

        ActiveRecord::Associations::Preloader.new.preload(projects, [
          :route,
          environments_for_dashboard: [
            # TODO: CI Vertical: cross-join
            # last_visible_pipeline: [
            #   :user,
            #   project: [:route, :group, :project_feature, namespace: :route]
            # ],
            last_visible_deployment: [
              deployable: [
                :metadata,
                :pipeline,
                project: [:project_feature, :group, :route, namespace: :route]
              ],
              project: [:route, namespace: :route]
            ],
            project: [:project_feature, :group, namespace: :route]
          ],
          namespace: [:route, :owner]
        ])

        projects
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
