# frozen_string_literal: true

class NamespaceStatistics < ApplicationRecord
  belongs_to :namespace

  validates :namespace, presence: true

  scope :for_namespaces, -> (namespaces) { where(namespace: namespaces) }

  def shared_runners_minutes(include_extra: true)
    minutes = shared_runners_seconds.to_i / 60

    include_extra ? minutes : minutes - Ci::Minutes::Quota.new(namespace).purchased_minutes_used
  end
end
