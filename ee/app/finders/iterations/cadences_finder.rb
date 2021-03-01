# frozen_string_literal: true

# Search for iterations cadences
#
# params - Hash
#   id: Find iterations cadence by its ID.
#   include_ancestor_groups: A flag to indicate if we should also look up iteration cadences in ancestor groups.
#   title - Filter by title with a fuzzy match.

module Iterations
  class CadencesFinder
    attr_reader :current_user, :group, :params

    ResourceNotFoundError = Class.new(RuntimeError)

    def initialize(current_user, group, params = {})
      @current_user = current_user
      @group = group
      @params = params
    end

    def execute
      raise ResourceNotFoundError, "Resource not found" unless group.iterations_cadences_enabled?

      items = Iterations::Cadence.all
      items = by_id(items)
      items = by_groups(items)
      items = by_title(items)
      items = by_duration(items)
      items = by_automatic(items)
      items = by_active(items)

      items.order(:title) # rubocop: disable CodeReuse/ActiveRecord
    end

    private

    def by_groups(items)
      items.with_groups(groups)
    end

    def groups
      groups = groups_to_include(group)

      # Because we are sure that all groups are in the same hierarchy tree
      # we can preset root group for all of them to optimize permission checks
      Group.preset_root_ancestor_for(groups)

      groups_user_can_read_cadences(groups).map(&:id)
    end

    def groups_to_include(group)
      groups = [group]
      groups += group.ancestors if include_ancestor_groups?

      groups
    end

    def groups_user_can_read_cadences(groups)
      DeclarativePolicy.user_scope do
        groups.select { |group| Ability.allowed?(current_user, :read_label, group) }
      end
    end

    def include_ancestor_groups?
      params[:include_ancestor_groups]
    end

    def by_id(items)
      if params[:id]
        items.id_in(params[:id])
      else
        items
      end
    end

    def by_title(items)
      if params[:title]
        items.search_title(params[:title])
      else
        items
      end
    end

    def by_duration(items)
      return items if params[:duration_in_weeks].blank?

      items.with_duration(params[:duration_in_weeks])
    end

    def by_automatic(items)
      return items if params[:automatic].nil?

      items.is_automatic(params[:automatic])
    end

    def by_active(items)
      return items if params[:active].nil?

      items.is_active(params[:active])
    end
  end
end
