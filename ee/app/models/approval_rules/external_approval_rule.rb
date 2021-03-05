# frozen_string_literal: true

module ApprovalRules
  class ExternalApprovalRule < ApplicationRecord
    self.table_name = 'external_approval_rules'
    scope :with_api_entity_associations, -> { preload(:protected_branches) }

    belongs_to :project
    has_and_belongs_to_many :protected_branches

    validates :external_url, presence: true, uniqueness: { scope: :project_id }, addressable_url: true
    validates :name, uniqueness: { scope: :project_id }, presence: true

    def async_execute(data)
      Gitlab::HTTP.post(external_url,
                        body: Gitlab::Json::LimitedEncoder.encode(data, limit: 25.megabytes), allow_local_requests: true)
    end
  end
end
