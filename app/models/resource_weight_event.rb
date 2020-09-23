# frozen_string_literal: true

class ResourceWeightEvent < ResourceEvent
  validates :issue, presence: true

  after_save :usage_metrics

  include IssueResourceEvent

  private

  def usage_metrics
    Gitlab::UsageDataCounters::IssueActivityUniqueCounter.track_issue_weight_changed_action(author: user)
  end
end
