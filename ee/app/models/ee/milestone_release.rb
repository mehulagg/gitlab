# frozen_string_literal: true

module EE
  module MilestoneRelease
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      validate :same_project_between_project_milestone_and_group

      def same_project_between_project_milestone_and_group
        return unless release_id_changed? || milestone_id_changed?

        return unless milestone&.group_id && release&.project_id

        return if release.project.feature_available?(:group_milestone_project_releases) && milestone.group.projects.where(id: release.project_id).exists?

        errors.add(:base, _('None of the group milestones have the same project as the release'))
      end
    end
  end
end
