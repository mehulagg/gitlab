# frozen_string_literal: true

module EE
  module NoteEntity
    extend ActiveSupport::Concern

    prepended do
      with_options if: -> (note, _) { note.system? && note.resource_parent.feature_available?(:description_diffs) } do
        expose :description_version_id

        expose :description_diff_path, if: -> (_) { description_version_id } do |note|
          description_diff_path(note.noteable, description_version_id)
        end

        expose :delete_description_version_path, if: -> (_) { description_version_id } do |note|
          delete_description_version_path(note.noteable, description_version_id)
        end

        expose :can_delete_description_version do |note|
          rule = "admin_#{object.noteable.class.to_ability_name}"

          Ability.allowed?(current_user, rule, object.noteable.resource_parent)
        end

        expose :description_version_deleted
      end

      private

      def description_version_id
        object.system_note_metadata&.description_version_id
      end

      def description_version_deleted
        object.system_note_metadata&.description_version&.deleted?
      end
    end
  end
end
