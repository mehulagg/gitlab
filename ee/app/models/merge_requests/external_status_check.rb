# frozen_string_literal: true

module MergeRequests
  class ExternalStatusCheck < ApplicationRecord
    self.table_name = 'external_status_checks'

    include IgnorableColumns
    ignore_column :external_approval_rule_id, remove_with: '14.3', remove_after: '2021-09-22'

    scope :with_api_entity_associations, -> { preload(:protected_branches) }

    belongs_to :project
    has_and_belongs_to_many :protected_branches

    validates :external_url, presence: true, uniqueness: { scope: :project_id }, addressable_url: true
    validates :name, uniqueness: { scope: :project_id }, presence: true

    def async_execute(data)
      puts data.inspect
      return unless protected_branches.none? || protected_branches.map(&:name).include?(data[:object_attributes][:target_branch])

      ApprovalRules::ExternalApprovalRulePayloadWorker.perform_async(self.id, payload_data(data))
    end

    def approved?(merge_request, sha)
      merge_request.status_check_responses.where(external_status_check: self, sha: sha).exists?
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
