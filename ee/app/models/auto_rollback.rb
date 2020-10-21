# frozen_string_literal: true

class AutoRollback < ApplicationRecord
  belongs_to :project, inverse_of: :auto_rollback

  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }
end
