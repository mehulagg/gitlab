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
    # as bulk insertion skips validations
    validates :rotation, presence: true
    validates :color_palette, presence: true
    validates :color_weight, presence: true
    validates :user, presence: true, uniqueness: { scope: :oncall_rotation_id }

    delegate :project, to: :rotation, allow_nil: true

    scope :not_removed, -> { where(is_removed: false) }
    scope :removed, -> { where(is_removed: true) }
    scope :for_user, ->(user) { where(user: user) }
  end
end
