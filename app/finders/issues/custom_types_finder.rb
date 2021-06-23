# frozen_string_literal: true

module Issues
  class CustomTypesFinder < UnionFinder
    include FinderMethods
    include FinderWithGroupHierarchy
    include Gitlab::Utils::StrongMemoize

    def initialize(current_user, params = {})
      @current_user = current_user
      @params = params
    end

    def execute(skip_authorization: false)
      @skip_authorization = skip_authorization

      items = find_union(item_ids, Issues::CustomType) || Issues::CustomType.none

      # items = with_title(items)
      # items = by_search(items)

      sort(items)
    end

    private

    attr_reader :current_user, :params, :skip_authorization

    # rubocop: disable CodeReuse/ActiveRecord
    def item_ids
      item_ids = []

      target_group = if group?
                       group
                     elsif project? && project && project.group.present?
                       project.group
                     end

      if target_group
        item_ids << Issues::CustomType.where(namespace_id: group_ids_for(target_group))
      end

      item_ids
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # rubocop: disable CodeReuse/ActiveRecord
    def sort(items)
      if params[:sort]
        items.order_by(params[:sort])
      else
        items.reorder(name: :asc)
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # rubocop: disable CodeReuse/ActiveRecord
    def with_name(items)
      return items if name.nil?
      return items.none if name.blank?

      items.where(name: name)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def by_search(items)
      return items unless search?

      items.search(params[:search])
    end

    def search?
      params[:search].present?
    end

    def title
      params[:title] || params[:name]
    end

    def read_permission
      :read_issue_custom_type
    end
  end
end
