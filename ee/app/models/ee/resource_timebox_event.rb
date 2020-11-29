# frozen_string_literal: true

module EE
  module ResourceTimeboxEvent
    extend ::Gitlab::Utils::Override

    private

    override :usage_metrics
    def usage_metrics
      case self
      when ResourceIterationEvent
        ::Gitlab::UsageDataCounters::IssueActivityUniqueCounter.track_issue_iteration_changed_action(author: user)
      else
        super
      end
    end
  end
end
