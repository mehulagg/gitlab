module EE
  module Ci
    # Build EE mixin
    #
    # This module is intended to encapsulate EE-specific model logic
    # and be included in the `Build` model
    module Build
      extend ActiveSupport::Concern

      CODEQUALITY_FILE = 'codeclimate.json'.freeze
      SAST_FILE = 'gl-sast-report.json'.freeze
      PERFORMANCE_FILE = 'performance.json'.freeze
      CLAIR_FILE = 'gl-clair-report.json'.freeze

      included do
        scope :codequality, ->() { where(name: %w[codequality codeclimate]) }
        scope :performance, ->() { where(name: %w[performance deploy]) }
        scope :sast, ->() { where(name: 'sast') }
        scope :clair, ->() { where(name: 'clair') }

        after_save :stick_build_if_status_changed
      end

      def shared_runners_minutes_limit_enabled?
        runner && runner.shared? && project.shared_runners_minutes_limit_enabled?
      end

      def stick_build_if_status_changed
        return unless status_changed?
        return unless running?

        ::Gitlab::Database::LoadBalancing::Sticking.stick(:build, id)
      end

      def has_codeclimate_json?
        has_artifact?(CODEQUALITY_FILE)
      end

      def has_performance_json?
        has_artifact?(PERFORMANCE_FILE)
      end

      def has_sast_json?
        has_artifact?(SAST_FILE)
      end

      def has_clair_json?
        has_artifact?(CLAIR_FILE)
      end

      private

      def has_artifact?(name)
        options.dig(:artifacts, :paths) == [name] &&
          artifacts_metadata?
      end
    end
  end
end
