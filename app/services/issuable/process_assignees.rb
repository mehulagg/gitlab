# frozen_string_literal: true

# This follows the rules specified in the specs.
# See spec/requests/api/graphql/mutations/merge_requests/set_assignees_spec.rb

class ProcessAssignees
  attr_accessor :assignee_ids, :add_assignee_ids, :remove_assignee_ids, :existing_assignee_ids, :extra_assignee_ids

  def initialize(params, existing_assignee_ids: nil, extra_assignee_ids: [])
    @assignee_ids = params.delete(:assignee_ids)
    @add_assignee_ids = params.delete(:add_assignee_ids)
    @remove_assignee_ids = params.delete(:remove_assignee_ids)
    @existing_assignee_ids = existing_assignee_ids
    @extra_assignee_ids = extra_assignee_ids
  end

  def execute
    compute_new_assignees

    updated_new_assignees = new_assignee_ids

    if replace_existing?
      updated_new_assignees = assignee_ids if assignee_ids
    else
      updated_new_assignees |= add_assignee_ids if add_assignee_ids
      updated_new_assignees -= remove_assignee_ids if remove_assignee_ids
    end

    updated_new_assignees.uniq
  end

  private

  def new_assignee_ids
    ids = existing_assignee_ids || assignee_ids || []

    ids | extra_assignee_ids
  end

  def replace_existing?
    # If we are not adding or removing, then we are replacing
    # all the existing assignee_ids.
    add_assignee_ids.blank? && remove_assignee_ids.blank?
  end
end
