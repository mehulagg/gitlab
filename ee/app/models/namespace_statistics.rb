# frozen_string_literal: true

class NamespaceStatistics < ApplicationRecord
  belongs_to :namespace

  validates :namespace, presence: true

  scope :for_namespaces, -> (namespaces) { where(namespace: namespaces) }

  def shared_runners_minutes(include_extra: true)
    minutes = shared_runners_seconds.to_i / 60

    include_extra ? minutes : minutes - extra_shared_runners_minutes
  end

  def extra_shared_runners_minutes
    limit = namespace.actual_shared_runners_minutes_limit(include_extra: false)
    extra_limit = namespace.extra_shared_runners_minutes_limit.to_i

    return 0 if extra_limit == 0 || shared_runners_minutes <= limit

    shared_runners_minutes - limit
  end
end
