# frozen_string_literal: true

# A component for rendering a collection of diffs
#
# `context` is required, and can be, for example, a `Commit` or a `MergeRequest`

class DiffsComponent < BaseComponent
  attr_reader :context, :diffs, :discussions, :environment

  alias_method :merge_request, :context
  alias_method :commit, :context

  def initialize(context:, diffs:, discussions:, environment: nil, page_context: nil, show_whitespace_toggle: true, diff_notes_disabled: false)
    @context = context
    @diffs = diffs
    @discussions = discussions
    @environment = environment
    @page_context = page_context
    @show_whitespace_toggle = show_whitespace_toggle
    @diff_notes_disabled = diff_notes_disabled
  end

  def project
    diffs.project
  end

  def diff_files
    diffs.diff_files
  end

  def header_cache_key
    #TODO: This needs to expire when the commit is updated somehow, like on force push
    @header_cache_key ||= [project, context, controller.controller_path, params[:page]]
  end

  def page_context
    @page_context ||=
      case context.class
      when Commit
        "is-commit"
      when MergeRequest
        "is-merge-request"
      end
  end

  def can_create_note?
    !@diff_notes_disabled && can?(current_user, :create_note, project)
  end

  def show_whitespace_toggle?
    @show_whitespace_toggle
  end

  def whitespace_toggle
    return unless show_whitespace_toggle?

    case
    when current_controller?(:commit)
      helpers.commit_diff_whitespace_link(project, context, class: 'd-none d-sm-inline-block')
    when current_controller?('projects/merge_requests/diffs')
      helpers.diff_merge_request_whitespace_link(project, context, class: 'd-none d-sm-inline-block')
    when current_controller?(:compare)
      helpers.diff_compare_whitespace_link(project, params[:from], params[:to], class: 'd-none d-sm-inline-block')
    when current_controller?(:wikis)
      helpers.toggle_whitespace_link(url_for(params_with_whitespace), class: 'd-none d-sm-inline-block')
    end
  end

  def render_overflow_warning?
    if diffs.raw_diff_files.any?(&:too_large?)
      Gitlab::Metrics.add_event(:diffs_overflow_single_file_limits)
    end

    diffs.raw_diff_files.overflow?.tap do |overflown|
      Gitlab::Metrics.add_event(:diffs_overflow_collection_limits) if overflown
    end
  end

  def expand_diffs_toggle
    return if diffs_expanded?
    return unless diff_files.any? { |diff_file| diff_file.collapsed? }

    link_to _('Expand all'), url_for(safe_params.merge(expanded: 1, format: nil)), class: 'gl-button btn btn-default'
  end

  def inline_diff_btn
    helpers.diff_btn('Inline', 'inline', helpers.diff_view == :inline)
  end

  def parallel_diff_btn
    helpers.diff_btn('Side-by-side', 'parallel', helpers.diff_view == :parallel)
  end

  def render_diffs
    render partial: 'projects/diffs/file',
      collection: diff_files,
      as: :diff_file,
      locals: {
        project: project,
        environment: environment,
        diff_page_context: page_context
      }
  end
end
