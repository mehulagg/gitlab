# frozen_string_literal: true

module Notes
  class UpdateService < BaseService
    def execute(note)
      return note unless note.editable? && params.present?

      old_mentioned_users = note.mentioned_users(current_user).to_a

      note.assign_attributes(params.merge(updated_by: current_user))

      note.with_transaction_returning_status do
        update_confidentiality(note)
        note.save
      end

      quick_actions_service = QuickActionsService.new(project, current_user)
      response = quick_actions_service.execute(note)

      note.note = response.content
      note.quick_action_response = response

      unless response.only_commands?
        note.create_new_cross_references!(current_user)
        update_todos(note, old_mentioned_users)
        update_suggestions(note)
      end

      if response.count > 0
        QuickActionsService.apply_updates(response, note) unless response.noop?

        if response.only_commands?
          delete_note(note, response.messages, response.warnings)
          note = nil # TODO: return the quick_action_response somehow
        else
          note.save
        end
      end

      note
    end

    private

    def delete_note(note, message, warnings)
      # We must add the error after we call #save because errors are reset
      # when #save is called
      note.errors.add(:commands_only, message.presence || _('Commands did not apply'))
      # Allow consumers to detect problems applying commands
      note.errors.add(:commands, warnings) if warnings.present?

      Notes::DestroyService.new(project, current_user).execute(note)
    end

    def update_suggestions(note)
      return unless note.supports_suggestion?

      Suggestion.transaction do
        note.suggestions.delete_all
        Suggestions::CreateService.new(note).execute
      end

      # We need to refresh the previous suggestions call cache
      # in order to get the new records.
      note.reset
    end

    def update_todos(note, old_mentioned_users)
      return unless note.previous_changes.include?('note')

      TodoService.new.update_note(note, current_user, old_mentioned_users)
    end

    # This method updates confidentiality of all discussion notes at once
    def update_confidentiality(note)
      return unless params.key?(:confidential)
      return unless note.is_a?(DiscussionNote) # we don't need to do bulk update for single notes
      return unless note.start_of_discussion? # don't update all notes if a response is being updated

      Note.id_in(note.discussion.notes.map(&:id)).update_all(confidential: params[:confidential])
    end
  end
end

Notes::UpdateService.prepend_if_ee('EE::Notes::UpdateService')
