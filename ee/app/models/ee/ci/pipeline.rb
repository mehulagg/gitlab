module EE
  module Ci
    module Pipeline
      EE_FAILURE_REASONS = {
        activity_limit_exceeded: 20,
        size_limit_exceeded: 21
      }.freeze

      def predefined_variables
        result = super
        result << { key: 'CI_PIPELINE_SOURCE', value: source.to_s, public: true }

        result
      end

      def codeclimate_artifact
        artifacts.codequality.find(&:has_codeclimate_json?)
      end

      def performance_artifact
        artifacts.performance.find(&:has_performance_json?)
      end

      def sast_artifact
        artifacts.sast.find(&:has_sast_json?)
      end

      def clair_artifact
        artifacts.clair.find(&:has_clair_json?)
      end
    end
  end
end
