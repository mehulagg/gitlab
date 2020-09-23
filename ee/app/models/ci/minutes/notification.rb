# frozen_string_literal: true

module Ci
  module Minutes
    class Notification
      PERCENTAGES = {
        warning: 30,
        danger: 5,
        exceeded: 0
      }.freeze

      def initialize(project, namespace)
        @context = Ci::Minutes::Context.new(project, namespace)
        @stage = calculate_notification_stage if eligible_for_notifications?
      end

      def show?(current_user)
        return false unless @stage
        return false unless @context.level

        Ability.allowed?(current_user, :read_ci_minutes_quota, @context.level)
      end

      def text
        contextual_map.dig(stage, :text)
      end

      def style
        contextual_map.dig(stage, :style)
      end

      def no_remaining_minutes?
        stage == :exceeded
      end

      def running_out?
        [:danger, :warning].include?(stage)
      end

      def stage_percentage
        PERCENTAGES[stage]
      end

      private

      attr_reader :context, :stage

      def eligible_for_notifications?
        context.shared_runners_minutes_limit_enabled?
      end

      def calculate_notification_stage
        percentage = context.shared_runners_remaining_minutes_percent.to_i

        if percentage <= PERCENTAGES[:exceeded]
          :exceeded
        elsif percentage <= PERCENTAGES[:danger]
          :danger
        elsif percentage <= PERCENTAGES[:warning]
          :warning
        end
      end

      def contextual_map
        {
          warning: {
            style: :warning,
            text: threshold_message
          },
          danger: {
            style: :danger,
            text: threshold_message
          },
          exceeded: {
            style: :danger,
            text: exceeded_message
          }
        }
      end

      def exceeded_message
        s_("Pipelines|Group %{namespace_name} has exceeded its pipeline minutes quota. " \
          "Unless you buy additional pipeline minutes, no new jobs or pipelines in its projects will run.") %
          { namespace_name: context.namespace_name }
      end

      def threshold_message
        s_("Pipelines|Group %{namespace_name} has %{percentage}%% or less Shared Runner Pipeline" \
          " minutes remaining.  Once it runs out, no new jobs or pipelines in its projects will run.") %
          {
            namespace_name: context.namespace_name,
            percentage: PERCENTAGES[stage]
          }
      end
    end
  end
end
