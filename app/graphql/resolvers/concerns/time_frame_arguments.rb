# frozen_string_literal: true

module TimeFrameArguments
  extend ActiveSupport::Concern

  included do
    argument :timeframe, Types::TimeframeInputType,
             required: false,
             description: 'List items overlapping the given timeframe.'
  end

  def transform_timeframe_parameters(args)
    return {} unless args[:timeframe]

    args[:timeframe].transform_keys { |k| :"#{k}_date" }
  end

  def transform_timeframe_parameters(args)
    if args[:timeframe]
      args[:timeframe].transform_keys { |k| :"#{k}_date" }
    else
      args.slice(:start_date, :end_date)
    end
  end
end
