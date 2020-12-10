# frozen_string_literal: true

module IncidentManagement
  class OncallParticipant < ApplicationRecord
    self.table_name = 'incident_management_oncall_participants'

    enum color_palette: Enums::DataVisualizationPalette.colors
    enum color_weight: Enums::DataVisualizationPalette.weights

    belongs_to :rotation, class_name: 'OncallRotation', foreign_key: :oncall_rotation_id
    belongs_to :user, class_name: 'User', foreign_key: :user_id
    has_many :shifts, class_name: 'OncallShift', inverse_of: :participant, foreign_key: :participant_id

    # Uniqueness validations added here should be duplicated
    # in IncidentManagement::OncallRotation::CreateService
    validates :rotation, presence: true
    validates :color_palette, presence: true
    validates :color_weight, presence: true
    validates :user, presence: true, uniqueness: { scope: :oncall_rotation_id }
    validate  :user_can_read_project, if: :user, on: :create

    delegate :project, to: :rotation, allow_nil: true

    scope :color_order, -> { order(:color_palette, :color_weight) }

    private

    def user_can_read_project
      unless user.can?(:read_project, project)
        errors.add(:user, 'does not have access to the project')
      end
    end
  end
end
