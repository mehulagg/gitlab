# frozen_string_literal: true

class IncidentManagement::MetricImagePolicy < BasePolicy
  delegate { @subject.incident }
end
