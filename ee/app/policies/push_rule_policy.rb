# frozen_string_literal: true

class PushRulePolicy < BasePolicy
  delegate { @subject.project }
end
