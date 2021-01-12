# frozen_string_literal: true

class AdminNote < ApplicationRecord
  belongs_to :namespace
  validates :namespace_id, presence: true
end
