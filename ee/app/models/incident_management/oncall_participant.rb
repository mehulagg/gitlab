# frozen_string_literal: true

module IncidentManagement
  class OncallParticipant < ApplicationRecord
    include BulkInsertSafe

    self.table_name = 'incident_management_oncall_participants'

    enum color_palette: Enums::DataVisualizationPalette.colors
    enum color_weight: Enums::DataVisualizationPalette.weights

    belongs_to :rotation, class_name: 'OncallRotation', foreign_key: :oncall_rotation_id
    belongs_to :user, class_name: 'User', foreign_key: :user_id

    validates :rotation, presence: true
    validates :color_palette, presence: true
    validates :color_weight, presence: true
    validates :user, presence: true, uniqueness: { scope: :oncall_rotation_id }
    validate  :user_can_read_project, if: :user, on: :create

    delegate :project, to: :rotation, allow_nil: true

    private

    def user_can_read_project
      unless user.can?(:read_project, project)
        errors.add(:user, 'does not have access to the project')
      end
    end
  end
end
