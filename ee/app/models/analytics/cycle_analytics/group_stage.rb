# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    class GroupStage < ApplicationRecord
      include Analytics::CycleAnalytics::Stage

      validates :group, presence: true
      validates :name, uniqueness: { scope: [:group_id, :group_value_stream_id] }
      belongs_to :group
      belongs_to :value_stream, class_name: 'Analytics::CycleAnalytics::GroupValueStream', foreign_key: :group_value_stream_id

      alias_attribute :parent, :group
      alias_attribute :parent_id, :group_id

      alias_attribute :value_stream_id, :group_value_stream_id

      def self.relative_positioning_query_base(stage)
        where(group_id: stage.group_id)
      end

      def self.relative_positioning_parent_column
        :group_id
      end
    end
  end
end
