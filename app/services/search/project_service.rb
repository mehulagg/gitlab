# frozen_string_literal: true

module Search
  class ProjectService
    attr_accessor :project, :current_user, :params

    def initialize(project, user, params)
      @project, @current_user, @params = project, user, params.dup
    end

    def execute
      Gitlab::ProjectSearchResults.new(current_user,
                                       params[:search],
                                       project: project,
                                       repository_ref: params[:repository_ref],
                                       filters: { confidential: params[:confidential], state: params[:state] }
                                      )
    end

    def scope
      @scope ||= begin
        allowed_scopes = %w[notes issues merge_requests milestones wiki_blobs commits users]

        allowed_scopes.delete(params[:scope]) { 'blobs' }
      end
    end
  end
end

Search::ProjectService.prepend_if_ee('EE::Search::ProjectService')
