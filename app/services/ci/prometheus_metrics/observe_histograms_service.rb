# frozen_string_literal: true

module Ci
  module PrometheusMetrics
    class ObserveHistogramsService
      Result = Struct.new(:status, :body, keyword_init: true)

      class << self
        def available_histograms
          @available_histograms ||= {
            'draw_links'   => histogram(:draw_links_total_duration_seconds, 'Total time spent drawing links, in seconds'),
            'other_metric' => histogram(:other_metric_definition_seconds, 'Description of this metric', { base: :label }, [0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.500, 2.0, 10.0])
          }
        end

        private

        def histogram(*attrs)
          proc { Gitlab::Metrics.histogram(*attrs) }
        end
      end

      def initialize(project, params)
        @project = project
        @params = params
      end

      def execute
        params
          .fetch(:histograms, [])
          .each(&method(:observe))

        Result.new(status: 201, body: {})
      end

      private

      attr_reader :project, :params

      def observe(data)
        histogram = find_histogram(data[:name])
        histogram.observe({ project: project.full_path }, data[:duration].to_i)
      end

      def find_histogram(name)
        self.class.available_histograms
          .fetch(name) { raise ActiveRecord::RecordNotFound }
          .call
      end
    end
  end
end
