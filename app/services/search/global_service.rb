module Search
  class GlobalService
    include Gitlab::CurrentSettings

    attr_accessor :current_user, :params
    attr_reader :default_project_filter

    def initialize(user, params)
      @current_user, @params = user, params.dup
      @default_project_filter = true
    end

    def execute
      if current_application_settings.elasticsearch_search?
        Gitlab::Elastic::SearchResults.new(current_user, params[:search], elastic_projects, elastic_global)
      else
        Gitlab::SearchResults.new(current_user, projects, params[:search],
                                  default_project_filter: default_project_filter)
      end
    end

    def projects
      @projects ||= ProjectsFinder.new(current_user: current_user).execute
    end

    def elastic_projects
      @elastic_projects ||=
        if current_user&.full_private_access?
          :any
        elsif current_user
          current_user.authorized_projects.pluck(:id)
        else
          []
        end
    end

    def elastic_global
      true
    end

    def scope
      @scope ||= begin
        allowed_scopes = %w[issues merge_requests milestones]
        allowed_scopes += %w[wiki_blobs blobs commits] if current_application_settings.elasticsearch_search?

        allowed_scopes.delete(params[:scope]) { 'projects' }
      end
    end
  end
end
