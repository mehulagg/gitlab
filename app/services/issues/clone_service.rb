# frozen_string_literal: true

module Issues
  class CloneService < Issuable::Clone::BaseService
    CloneError = Class.new(StandardError)

    attr_reader :with_notes

    def execute(issue, target_project, with_notes: false)
      @target_project = target_project
      @with_notes = with_notes

      unless issue.can_clone?(current_user, @target_project)
        raise CloneError, s_('CloneIssue|Cannot clone issue due to insufficient permissions!')
      end

      super(issue, target_project)

      queue_copy_designs

      new_entity
    end

    private

    attr_reader :target_project

    def update_new_entity
      # we don't call `super` because we want to be able to decide whether or not to copy all comments over.
      update_new_entity_description
      update_new_entity_attributes
      copy_award_emoji
      copy_notes if with_notes
    end

    def update_old_entity
      # no-op
      # The base_service closes the old issue, we don't want that, so we override here so nothing happens.
    end

    def create_new_entity
      new_params = {
        id: nil,
        iid: nil,
        project: target_project,
        author: original_entity.author,
        assignee_ids: original_entity.assignee_ids,
        moved_issue: true
      }

      new_params = original_entity.serializable_hash.symbolize_keys.merge(new_params)

      # Skip creation of system notes for existing attributes of the issue. The system notes of the old
      # issue are copied over so we don't want to end up with duplicate notes.
      CreateService.new(@target_project, @current_user, new_params).execute(skip_system_notes: true)
    end

    def queue_copy_designs
      return unless original_entity.designs.present?

      response = DesignManagement::CopyDesignCollection::QueueService.new(
        current_user,
        original_entity,
        new_entity
      ).execute

      log_error(response.message) if response.error?
    end

    def add_note_from
      SystemNoteService.noteable_cloned(new_entity, target_project,
        original_entity, current_user,
        direction: :from)
    end

    def add_note_to
      SystemNoteService.noteable_cloned(original_entity, old_project,
        new_entity, current_user,
        direction: :to)
    end
  end
end
