# frozen_string_literal: true

module Gitlab
  module Experimentation
    class Experiment
      attr_reader :tracking_category, :use_backwards_compatible_subject_index

      def initialize(key, **options)
        @environment = options[:environment]
        @tracking_category = options[:tracking_category]
        @use_backwards_compatible_subject_index = options[:use_backwards_compatible_subject_index]

        @experiment_percentage ||= Feature.get(:"#{key}_experiment_percentage").percentage_of_time_value # rubocop:disable Gitlab/AvoidFeatureGet
      end

      def enabled?
        experiment_percentage > 0
      end

      def enabled_for_environment?
        return ::Gitlab.dev_env_or_com? if environment.nil?

        environment
      end

      def enabled_for_index?(index)
        return false if index.blank?

        index <= experiment_percentage
      end

      private

      attr_reader :environment, :experiment_percentage
    end
  end
end
