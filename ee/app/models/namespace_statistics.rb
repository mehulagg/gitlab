# frozen_string_literal: true

class NamespaceStatistics < ApplicationRecord
  belongs_to :namespace

  validates :namespace, presence: true

  scope :for_namespaces, -> (namespaces) { where(namespace: namespaces) }
  scope :with_any_ci_minutes_used, -> { where.not(shared_runners_seconds: 0) }
end
