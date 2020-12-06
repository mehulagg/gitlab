# frozen_string_literal: true

module IncidentManagement
  class OncallParticipant < ApplicationRecord
    include BulkInsertSafe

    self.table_name = 'incident_management_oncall_participants'

    enum color_palette: Enums::DataVisualizationPalette.colors
    enum color_weight: Enums::DataVisualizationPalette.weights

    belongs_to :oncall_rotation, foreign_key: :oncall_rotation_id
    belongs_to :participant, class_name: 'User', foreign_key: :user_id

    validates :oncall_rotation, presence: true
    validates :color_palette, presence: true
    validates :color_weight, presence: true
    validates :participant, presence: true, uniqueness: { scope: :oncall_rotation_id }
    validate  :participant_can_read_project, if: :participant, on: :create

    alias_attribute :user, :participant

    delegate :project, to: :oncall_rotation, allow_nil: true

    private

    def participant_can_read_project
      unless participant.can?(:read_project, project)
        errors.add(:participant, 'does not have access to the project')
      end
    end
  end
end
