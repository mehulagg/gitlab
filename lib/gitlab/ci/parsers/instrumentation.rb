# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Instrumentation
        def parse!(*args)
          parser_result = nil

          duration = Benchmark.realtime do
            parser_result = super(*args)
          end

          histogram = Gitlab::Metrics.histogram(:ci_report_parser_duration_seconds, 'Duration of parsing a CI report artifact')
          histogram.observe({ parser: self.class.name }, duration)

          parser_result
        end
      end
    end
  end
end
