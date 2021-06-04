# frozen_string_literal: true

module TimeFrameArguments
  extend ActiveSupport::Concern

  OVERLAPPING_TIMEFRAME_DESC = 'List items overlapping a time frame defined by startDate..endDate (if one date is provided, both must be present)'

  included do
    argument :timeframe, Types::TimeframeInputType,
             required: false,
             description: 'List items overlapping the given timeframe.'
  end
end
