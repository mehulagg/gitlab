# frozen_string_literal: true

module EE
  module ProjectGroupLink
    extend ActiveSupport::Concern

    prepended do
      before_destroy :delete_related_access_levels

      after_commit :update_gitlab_subscription
    end

    def delete_related_access_levels
      return unless group.present? && project.present?

      # For protected branches
      project.protected_branches.merge_access_by_group(group).destroy_all # rubocop: disable DestroyAll
      project.protected_branches.push_access_by_group(group).destroy_all # rubocop: disable DestroyAll

      # For protected tags
      project.protected_tags.create_access_by_group(group).delete_all

      # For protected environments
      project.protected_environments.deploy_access_levels_by_group(group).delete_all
    end

    private

    def update_gitlab_subscription
      ::Gitlab::Subscription::MaxSeatsUpdater.update(project)
    end
  end
end
