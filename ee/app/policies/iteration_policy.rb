# frozen_string_literal: true

class IterationPolicy < BasePolicy
  delegate { @subject.resource_parent }
end
