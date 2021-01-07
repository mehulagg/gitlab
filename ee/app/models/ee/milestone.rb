# frozen_string_literal: true

module EE
  module Milestone
    extend ActiveSupport::Concern

    prepended do
      include Elastic::ApplicationVersionedSearch

      has_many :boards
    end

    def supports_milestone_charts?
      resource_parent&.feature_available?(:milestone_charts) && weight_available?
    end

    alias_method :supports_timebox_charts?, :supports_milestone_charts?
  end
end
