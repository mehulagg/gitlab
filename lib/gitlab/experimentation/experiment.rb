# frozen_string_literal: true

module Gitlab
  module Experimentation
    class Experiment
      attr_reader :tracking_category, :use_backwards_compatible_subject_index

      def initialize(key, **params)
        @key = key
        @tracking_category = params[:tracking_category]
        @use_backwards_compatible_subject_index = params[:use_backwards_compatible_subject_index]

        @experiment_percentage = Feature.get(:"#{key}_experiment_percentage").percentage_of_time_value # rubocop:disable Gitlab/AvoidFeatureGet
      end

      def active?
        ::Gitlab.dev_env_or_com? && experiment_percentage > 0
      end

      def enabled_for_subject?(subject)
        return false if subject.blank?

        index = index_from_subject(subject)

        index <= experiment_percentage
      end

      private

      attr_reader :experiment_percentage, :key

      def index_from_subject(subject)
        index = if use_backwards_compatible_subject_index
          Digest::SHA1.hexdigest(subject_id(subject)).hex
        else
          Zlib.crc32("#{key}#{subject_id(subject)}")
        end

        index % 100
      end

      def subject_id(subject)
        if subject.respond_to?(:to_global_id)
          subject.to_global_id.to_s
        elsif subject.respond_to?(:to_s)
          subject.to_s
        else
          raise ArgumentError.new('Subject must respond to `to_global_id` or `to_s`')
        end
      end
    end
  end
end
