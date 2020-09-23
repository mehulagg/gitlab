# frozen_string_literal: true

module EE
  module WeightEventable
    extend ActiveSupport::Concern

    included do
      has_many :resource_weight_events
    end

    def previous_weight
      previous_changes['weight']&.first
    end

    # We want to know if resource already had a weight but no weight tracking events(i.e. no resource_weight_events record)
    # in which case we will create a historical resource_weight_event record with last known weight. That is to try and
    # populate more data when tracking changes, without having a huge migration parsing weight change notes.
    #
    # At some point this should be removed, when we will have enough historical data and it will be of no use:
    # https://gitlab.com/gitlab-org/gitlab/issues/208785
    def first_weight_event?
      previous_weight.present? && resource_weight_events.none?
    end
  end
end
