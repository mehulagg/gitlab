# frozen_string_literal: true

class ExternalApprovalRule < ApplicationRecord
  belongs_to :project
  has_and_belongs_to_many :protected_branches

  validates :external_url, presence: true
end
