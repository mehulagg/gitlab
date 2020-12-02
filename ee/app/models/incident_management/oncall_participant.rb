# frozen_string_literal: true

module IncidentManagement
  class OncallParticipant < ApplicationRecord
    include BulkInsertSafe

    self.table_name = 'incident_management_oncall_participants'

    belongs_to :oncall_rotation, foreign_key: :oncall_rotation_id
    belongs_to :participant, class_name: 'User', foreign_key: :user_id

    validates :oncall_rotation, presence: true
    validates :color_palette, length: { maximum: 10 }
    validates :color_weight, length: { maximum: 4 }
    validates :participant, presence: true, uniqueness: { scope: :oncall_rotation_id }
    validate  :particpant_can_read_project, if: :participant

    alias_attribute :user, :participant

    delegate :project, to: :oncall_rotation, allow_nil: true

    private

    def particpant_can_read_project
      unless participant.can?(:read_project, project)
        errors.add(:participant, 'participant does not have access to the project')
      end
    end
  end
end
