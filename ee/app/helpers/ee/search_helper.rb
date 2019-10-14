# frozen_string_literal: true
module EE
  module SearchHelper
    extend ::Gitlab::Utils::Override

    override :search_filter_input_options
    def search_filter_input_options(type)
      options = super
      options[:data][:'multiple-assignees'] = 'true' if search_multiple_assignees?(type)

      options
    end

    override :find_project_for_result_blob
    def find_project_for_result_blob(projects, result)
      return super if result.is_a?(::Gitlab::Search::FoundBlob)

      super || projects&.find { |project| project.id == blob_project_id(result) }
    end

    override :blob_projects
    def blob_projects(results)
      return super if results.first.is_a?(::Gitlab::Search::FoundBlob)

      project_ids = results.map(&method(:blob_project_id))

      ::ProjectsFinder.new(current_user: current_user, project_ids_relation: project_ids).execute
    end

    override :parse_search_result
    def parse_search_result(result)
      return super if result.is_a?(::Gitlab::Search::FoundBlob)

      ::Gitlab::Elastic::SearchResults.parse_search_result(result)
    end

    override :search_blob_title
    def search_blob_title(project, file_name)
      if @project
        file_name
      else
        (project.full_name + ': ' + content_tag(:i, file_name)).html_safe
      end
    end

    # This is a special case for snippet searches in .com.
    # The scope used to gather the snippets is too wide and
    # we have to process a lot of them, what leads to time outs.
    # We're reducing the scope only in .com because the current
    # one is still valid in smaller installations.
    # https://gitlab.com/gitlab-org/gitlab/issues/26123
    override :search_entries_info_template
    def search_entries_info_template(collection)
      return super unless gitlab_com_snippet_db_search?

      if collection.total_pages > 1
        s_("SearchResults|Showing %{from} - %{to} of %{count} %{scope} for \"%{term}\" in your personal and project snippets")
      else
        s_("SearchResults|Showing %{count} %{scope} for \"%{term}\" in your personal and project snippets")
      end
    end

    private

    def search_multiple_assignees?(type)
      context = @project.presence || @group.presence || :dashboard

      type == :issues && (context == :dashboard ||
        context.feature_available?(:multiple_issue_assignees))
    end

    def blob_project_id(blob_result)
      blob_result.dig('_source', 'join_field', 'parent')&.split('_')&.last.to_i
    end

    def gitlab_com_snippet_db_search?
      @current_user &&
        @show_snippets &&
        ::Gitlab.com? &&
        ::Feature.enabled?(:restricted_snippet_scope_search, default_enabled: true) &&
        ::Gitlab::CurrentSettings.search_using_elasticsearch?(scope: nil)
    end
  end
end
