# frozen_string_literal: true

class ExperimentUser < ApplicationRecord
  belongs_to :experiment
  belongs_to :user

  enum group_type: { control: 0, experimental: 1 }

  validates :experiment_id, presence: true
  validates :user_id, presence: true
  validates :group_type, presence: true
end
