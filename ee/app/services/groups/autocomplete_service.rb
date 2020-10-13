# frozen_string_literal: true

module Groups
  class AutocompleteService < Groups::BaseService
    include LabelsAsHash

    # rubocop: disable CodeReuse/ActiveRecord
    def issues(confidential_only: false, issue_types: nil)
      finder_params = { group_id: group.id, include_subgroups: true, state: 'opened' }
      finder_params[:confidential] = true if confidential_only.present?
      finder_params[:issue_types] = issue_types if issue_types.present?

      IssuesFinder.new(current_user, finder_params)
        .execute
        .preload(project: :namespace)
        .select(:iid, :title, :project_id)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # rubocop: disable CodeReuse/ActiveRecord
    def merge_requests
      MergeRequestsFinder.new(current_user, group_id: group.id, include_subgroups: true, state: 'opened')
        .execute
        .preload(target_project: :namespace)
        .select(:iid, :title, :target_project_id)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def epics(confidential_only: false)
      finder_params = { group_id: group.id }
      finder_params[:confidential] = true if confidential_only.present?

      # TODO: use include_descendant_groups: true optional parameter once frontend supports epics from external groups.
      # See https://gitlab.com/gitlab-org/gitlab/issues/6837
      EpicsFinder.new(current_user, finder_params)
        .execute
        .select(:iid, :title)
    end

    def vulnerabilities
      ::Autocomplete::VulnerabilitiesAutocompleteFinder
        .new(current_user, group, params)
        .execute
        .select([:id, :title, :project_id])
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def milestones
      group_ids = group.self_and_ancestors.public_or_visible_to_user(current_user).pluck(:id)

      MilestonesFinder.new(group_ids: group_ids).execute.select(:iid, :title)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def labels_as_hash(target)
      super(target, group_id: group.id, only_group_labels: true, include_ancestor_groups: true)
    end

    def commands(noteable)
      return [] unless noteable

      QuickActions::InterpretService.new(nil, current_user).available_commands(noteable)
    end
  end
end
