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
      ApprovalRules::ExternalApprovalRulePayloadWorker.perform_async(self.id, payload_data(data))
    end

    def approved?(merge_request, sha)
      merge_request.status_check_responses.where(external_approval_rule: self, sha: sha).exists?
    end

    def to_h
      {
        id: self.id,
        name: self.name,
        external_url: self.external_url
      }
    end

    private

    def payload_data(merge_request_hook_data)
      merge_request_hook_data.merge(external_approval_rule: self.to_h)
    end
  end
end
