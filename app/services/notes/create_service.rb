# frozen_string_literal: true

module Notes
  class CreateService < ::Notes::BaseService
    def execute
      note = Notes::BuildService.new(project, current_user, params.except(:merge_request_diff_head_sha)).execute

      # n+1: https://gitlab.com/gitlab-org/gitlab-foss/issues/37440
      note_valid = Gitlab::GitalyClient.allow_n_plus_1_calls do
        # We may set errors manually in Notes::BuildService for this reason
        # we also need to check for already existing errors.
        note.errors.empty? && note.valid?
      end

      return note unless note_valid

      # We execute commands (extracted from `params[:note]`) on the noteable
      # **before** we save the note because if the note consists of commands
      # only, there is no need be create a note!

      execute_quick_actions(note) do |only_commands|
        note.run_after_commit do
          # Finish the harder work in the background
          NewNoteWorker.perform_async(note.id)
        end

        note_saved = note.with_transaction_returning_status do
          !only_commands && note.save
        end

        when_saved(note) if note_saved
      end

      note
    end

    private

    def execute_quick_actions(note)
      return yield(false) unless quick_actions_service.supported?(note)

      content, update_params, message = quick_actions_service.execute(note, quick_action_options)
      only_commands = content.empty?
      note.note = content

      yield(only_commands)

      do_commands(note, update_params, message, only_commands)
    end

    def quick_actions_service
      @quick_actions_service ||= QuickActionsService.new(project, current_user)
    end

    def when_saved(note)
      if note.part_of_discussion? && note.discussion.can_convert_to_discussion?
        note.discussion.convert_to_discussion!(save: true)
      end

      todo_service.new_note(note, current_user)
      clear_noteable_diffs_cache(note)
      Suggestions::CreateService.new(note).execute
      increment_usage_counter(note)

      if Feature.enabled?(:notes_create_service_tracking, project)
        Gitlab::Tracking.event('Notes::CreateService', 'execute', tracking_data_for(note))
      end

      if Feature.enabled?(:merge_ref_head_comments, project, default_enabled: true) && note.for_merge_request? && note.diff_note? && note.start_of_discussion?
        Discussions::CaptureDiffNotePositionService.new(note.noteable, note.diff_file&.paths).execute(note.discussion)
      end
    end

    def do_commands(note, update_params, message, only_commands)
      return if quick_actions_service.commands_executed_count.to_i == 0

      if update_params.present?
        quick_actions_service.apply_updates(update_params, note)
        note.commands_changes = update_params
      end

      # We must add the error after we call #save because errors are reset
      # when #save is called
      if only_commands
        note.errors.add(:commands_only, message.presence || _('Failed to apply commands.'))
        # Allow consumers to detect problems applying commands
        note.errors.add(:commands, _('Failed to apply commands.')) unless message.present?
      end
    end

    def quick_action_options
      {
        merge_request_diff_head_sha: params[:merge_request_diff_head_sha],
        review_id: params[:review_id]
      }
    end

    def tracking_data_for(note)
      label = Gitlab.ee? && note.author == User.visual_review_bot ? 'anonymous_visual_review_note' : 'note'

      {
        label: label,
        value: note.id
      }
    end
  end
end
