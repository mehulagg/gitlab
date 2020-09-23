# frozen_string_literal: true

module Geo
  module Eventable
    extend ActiveSupport::Concern
    include ::EachBatch
    include ::DeleteWithLimit

    included do
      has_one :geo_event_log, class_name: 'Geo::EventLog'
    end

    class_methods do
      def up_to_event(geo_event_log_id)
        joins(:geo_event_log)
          .where(Geo::EventLog.arel_table[:id].lteq(geo_event_log_id))
      end
    end

    def consumer_klass_name
      self.class.name.demodulize
    end
  end
end
