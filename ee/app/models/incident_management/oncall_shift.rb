# frozen_string_literal: true

module IncidentManagement
  class OncallShift < ApplicationRecord
    belongs_to :oncall_rotation, inverse_of: 'oncall_shifts', foreign_key: 'oncall_rotation_id'
    belongs_to :participant, class_name: 'User', foreign_key: :user_id

    validates :starts_at, presence: true
    validates :ends_at, presence: true
  end
end
