# frozen_string_literal: true

class UsersOpsDashboardProject < ApplicationRecord
  include UsageStatistics

  belongs_to :project
  belongs_to :user

  validates :user, presence: true
  validates :user_id, uniqueness: { scope: [:project_id] }
  validates :project, presence: true
end
