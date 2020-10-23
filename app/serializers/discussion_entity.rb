# frozen_string_literal: true

class DiscussionEntity < Grape::Entity
  include RequestAwareEntity
  include NotesHelper

  expose :id, :reply_id
  expose :position, if: -> (d, _) { d.diff_discussion? && !d.legacy_diff_discussion? }
  expose :original_position, if: -> (d, _) { d.diff_discussion? && !d.legacy_diff_discussion? }
  expose :line_code, if: -> (d, _) { d.diff_discussion? }
  expose :expanded?, as: :expanded
  expose :active?, as: :active, if: -> (d, _) { d.diff_discussion? }
  expose :project_id

  expose :notes do |discussion, opts|
    request.note_entity.represent(discussion.notes, opts)
  end

  expose :discussion_path do |discussion|
    discussion_path(discussion)
  end

  expose :positions, if: -> (d, _) { display_merge_ref_discussions?(d) } do |discussion|
    discussion.diff_note_positions.map(&:position)
  end

  expose :line_codes, if: -> (d, _) { display_merge_ref_discussions?(d) } do |discussion|
    discussion.diff_note_positions.map(&:line_code)
  end

  expose :individual_note?, as: :individual_note
  expose :resolvable do |discussion|
    discussion.resolvable?
  end

  expose :resolved?, as: :resolved
  expose :resolved_by_push?, as: :resolved_by_push
  expose :resolved_by, using: NoteUserEntity
  expose :resolved_at
  expose :resolve_path, if: -> (d, _) { d.resolvable? } do |discussion|
    resolve_project_merge_request_discussion_path(discussion.project, discussion.noteable, discussion.id)
  end
  expose :resolve_with_issue_path, if: -> (d, _) { d.resolvable? } do |discussion|
    new_project_issue_path(discussion.project, merge_request_to_resolve_discussions_of: discussion.noteable.iid, discussion_to_resolve: discussion.id)
  end

  expose :diff_file, using: DiscussionDiffFileEntity, if: -> (d, _) { d.diff_discussion? }

  expose :diff_discussion?, as: :diff_discussion

  expose :truncated_diff_lines_path, if: -> (d, _) { !d.expanded? && !render_truncated_diff_lines? } do |discussion|
    project_merge_request_discussion_path(discussion.project, discussion.noteable, discussion)
  end

  expose :truncated_diff_lines, using: DiffLineEntity, if: -> (d, _) { d.diff_discussion? && d.on_text? && (d.expanded? || render_truncated_diff_lines?) }

  expose :for_commit?, as: :for_commit
  expose :commit_id
  expose :confidential?, as: :confidential

  expose :current_user do
    expose :can_resolve do |discussion|
      discussion.resolvable? && discussion.can_resolve?(current_user)
    end
  end

  private

  def render_truncated_diff_lines?
    options[:render_truncated_diff_lines]
  end

  def current_user
    request.current_user
  end

  def display_merge_ref_discussions?(discussion)
    discussion.diff_discussion? && !discussion.legacy_diff_discussion?
  end
end
