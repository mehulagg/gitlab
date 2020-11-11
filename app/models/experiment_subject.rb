# frozen_string_literal: true

class ExperimentSubject < ApplicationRecord
  belongs_to :experiment
  belongs_to :user
  belongs_to :group
  belongs_to :project
end
