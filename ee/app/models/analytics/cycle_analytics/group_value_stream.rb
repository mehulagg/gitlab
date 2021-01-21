# frozen_string_literal: true

class Analytics::CycleAnalytics::GroupValueStream < ApplicationRecord
  belongs_to :group

  has_many :stages, class_name: 'Analytics::CycleAnalytics::GroupStage'

  validates :group, :name, presence: true
  validates :name, length: { minimum: 3, maximum: 100, allow_nil: false }, uniqueness: { scope: :group_id }

  def custom?
    name != Analytics::CycleAnalytics::Stages::BaseService::DEFAULT_VALUE_STREAM_NAME
  end
end
