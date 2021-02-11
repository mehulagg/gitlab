# frozen_string_literal: true

module ApprovalRules
  class ExternalApprovalRule < ApplicationRecord
    belongs_to :project
    has_and_belongs_to_many :protected_branches

    validates :external_url, presence: true, uniqueness: { scope: :project_id }, addressable_url: true
    validates :name, uniqueness: { scope: :project_id }
  end
end
