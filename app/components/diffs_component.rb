# frozen_string_literal: true

class DiffsComponent < BaseComponent
  attr_reader :context, :diffs

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

  def expand_diffs_toggle
    return if diffs_expanded?
    return unless diff_files.any? { |diff_file| diff_file.collapsed? }

    link_to _('Expand all'), url_for(safe_params.merge(expanded: 1, format: nil)), class: 'gl-button btn btn-default'
  end
end
