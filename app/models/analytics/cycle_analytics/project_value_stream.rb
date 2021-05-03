# frozen_string_literal: true

class Analytics::CycleAnalytics::ProjectValueStream < ApplicationRecord
  belongs_to :project

  validates :project, :name, presence: true
  validates :name, length: { minimum: 3, maximum: 100, allow_nil: false }, uniqueness: { scope: :project_id }

  def custom?
    false
  end

  def stages
    []
  end
end
