# frozen_string_literal: true

class IssuableMetricImagePolicy < BasePolicy
  delegate { @subject.issue }
end
