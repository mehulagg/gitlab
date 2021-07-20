# frozen_string_literal: true

class ErrorTracking::ClientKey < ApplicationRecord
  belongs_to :project

  validates :project, presence: true
  validates :public_key, presence: true
end
