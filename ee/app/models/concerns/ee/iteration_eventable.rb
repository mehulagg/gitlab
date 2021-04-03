# frozen_string_literal: true

module EE
  module IterationEventable
    extend ActiveSupport::Concern

    included do
      has_many :resource_iteration_events
    end
  end
end
