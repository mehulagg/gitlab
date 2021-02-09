# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    class StageEntity < Grape::Entity
      expose :title
      expose :hidden
      expose :legend
      expose :description
      expose :id
      expose :custom
      expose :start_event_identifier, if: -> (s) { s.custom? }
      expose :end_event_identifier, if: -> (s) { s.custom? }
      expose :start_event_label, using: LabelEntity, if: -> (s) { s.start_event_label_based? }
      expose :end_event_label, using: LabelEntity, if: -> (s) { s.end_event_label_based? }

      def id
        object.id || object.name
      end
    end
  end
end
