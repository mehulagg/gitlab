# frozen_string_literal: true
module EE
  module SearchHelper
    extend ::Gitlab::Utils::Override

    SWITCH_TO_BASIC_SEARCHABLE_TABS = %w[projects issues merge_requests milestones users epics].freeze

    override :search_filter_input_options
    def search_filter_input_options(type, placeholder = _('Search or filter results...'))
      options = super
      options[:data][:'multiple-assignees'] = 'true' if search_multiple_assignees?(type)

      if @project&.group
        options[:data]['epics-endpoint'] = group_epics_path(@project.group)
      elsif @group.present?
        options[:data]['epics-endpoint'] = group_epics_path(@group)
      end

      options
    end

    override :search_blob_title
    def search_blob_title(project, path)
      if @project
        path
      else
        (project.full_name + ': ' + content_tag(:i, path)).html_safe
      end
    end

    override :project_autocomplete
    def project_autocomplete
      return super unless @project && @project.feature_available?(:repository)

      super + [{ category: "In this project", label: _("Feature Flags"), url: project_feature_flags_path(@project) }]
    end

    override :search_entries_scope_label
    def search_entries_scope_label(scope, count)
      case scope
      when 'epics'
        ns_('SearchResults|epic', 'SearchResults|epics', count)
      else
        super
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
        s_("SearchResults|Showing %{from} - %{to} of %{count} %{scope} for%{term_element} in your personal and project snippets").html_safe
      else
        s_("SearchResults|Showing %{count} %{scope} for%{term_element} in your personal and project snippets").html_safe
      end
    end

    override :highlight_and_truncate_issue
    def highlight_and_truncate_issue(issue, search_term, search_highlight)
      return super unless search_service.use_elasticsearch? && search_highlight[issue.id]&.description.present?

      # We use Elasticsearch highlighting for results from Elasticsearch
      Truncato.truncate(search_highlight[issue.id].description.first, count_tags: false, count_tail: false, max_length: 200).html_safe
    end

    private

    def search_multiple_assignees?(type)
      context = @project.presence || @group.presence || :dashboard

      type == :issues && (context == :dashboard ||
        context.feature_available?(:multiple_issue_assignees))
    end

    def gitlab_com_snippet_db_search?
      @current_user &&
        @show_snippets &&
        ::Gitlab.com? &&
        ::Gitlab::CurrentSettings.search_using_elasticsearch?(scope: nil)
    end
  end
end
