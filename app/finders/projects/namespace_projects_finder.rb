# frozen_string_literal: true

# NamespaceProjectsFinder
#
# Used to filter Projects by set of params
#
# Arguments:
#   current_user
#   namespace
#   params:
#     sort: string
#     search: string
#     include_subgroups: boolean
#     ids: int[]
#
module Projects
  class NamespaceProjectsFinder
    attr_reader :namespace, :params, :current_user

    def initialize(namespace: nil, params: {}, current_user: nil)
      @namespace = namespace
      @params = params
      @current_user = current_user
    end

    def execute
      return Project.none if namespace.nil?

      collection = if params[:include_subgroups].present?
                     namespace.all_projects.with_route
                   else
                     namespace.projects.with_route
                   end

      collection = filter_projects(collection)
      collection
    end

    private

    def filter_projects(collection)
      collection = by_ids(collection)
      collection = sort(collection)
      collection
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def by_ids(items)
      params[:ids].present? ? items.where(id: params[:ids]) : items
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def sort(items)
      return items unless params[:search]

      if params[:sort].present? && params[:sort] == :similarity
        items.sorted_by_similarity_desc(params[:search], include_in_select: true).merge(Project.search(params[:search]))
      else
        items.merge(Project.search(params[:search]))
      end
    end
  end
end

Projects::NamespaceProjectsFinder.prepend_if_ee('::EE::Projects::NamespaceProjectsFinder')
