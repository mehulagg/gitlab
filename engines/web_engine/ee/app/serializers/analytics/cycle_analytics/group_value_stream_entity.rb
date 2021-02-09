# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    class GroupValueStreamEntity < Grape::Entity
      expose :name
      expose :id
      expose :is_custom do |object|
        object.custom?
      end

      private

      def id
        object.id || object.name # use the name `default` if the record is not persisted
      end
    end
  end
end
