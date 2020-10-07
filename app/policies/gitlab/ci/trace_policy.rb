# frozen_string_literal: true

module Gitlab
  module Ci
    class TracePolicy < BasePolicy
      delegate(:job)
    end
  end
end
