# frozen_string_literal: true
module EE
  module Gitlab
    module BackgroundMigration
      # This migration populates issues that were promoted to epics
      # and have null promoted_to_epic_id.
      # For more information please check https://gitlab.com/gitlab-org/gitlab/issues/194177
      module FixOrphanPromotedIssues
        extend ::Gitlab::Utils::Override

        override :perform
        def perform(note_id)
          ActiveRecord::Base.connection.execute <<~SQL
            WITH promotion_notes AS #{::Gitlab::Database::AsWithMaterialized.materialized_if_supported} (
              SELECT noteable_id, note as promotion_note, projects.namespace_id as epic_group_id FROM notes
              INNER JOIN projects ON notes.project_id = projects.id
              WHERE notes.noteable_type = 'Issue'
              AND notes.system IS TRUE
              AND notes.note like 'promoted to epic%'
              AND notes.id = #{Integer(note_id)}
            ), promoted_epics AS #{::Gitlab::Database::AsWithMaterialized.materialized_if_supported} (
              SELECT epics.id as promoted_epic_id, promotion_notes.noteable_id as issue_id FROM epics
              INNER JOIN promotion_notes on epics.group_id = promotion_notes.epic_group_id
              WHERE concat('promoted to epic &', epics.iid) = promotion_notes.promotion_note
            )
            UPDATE issues
            SET promoted_to_epic_id = promoted_epic_id
            FROM promoted_epics
            WHERE issues.id = promoted_epics.issue_id
            AND issues.promoted_to_epic_id IS NULL
          SQL
        rescue ArgumentError
        end
      end
    end
  end
end
