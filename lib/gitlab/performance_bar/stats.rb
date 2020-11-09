module Gitlab
  module PerformanceBar
    class Stats
      def process(request)
        return unless request

        data = Gitlab::Json.parse(request)
        queries = sql_queries(data)
        grouped_queries = queries.group_by { |q| [q[:filename], q[:method]] }

        queries.each do |query|
          duration = query.delete(:duration)
          query_key = [query[:filename], query[:method]]

          duration_histogram.observe(query, duration)
          frequency_histogram.observe(query, grouped_queries[query_key].size)
        end
      end

      private

      def sql_queries(data)
        return [] unless queries = data.dig('data', 'active-record', 'details')

        queries.map do |query|
          filename, method = parse_backtrace(query['backtrace'])

          {
            filename: filename,
            method: method,
            duration: query['duration'].to_f
          }
        end
      end

      def parse_backtrace(backtrace)
        # sample:
        # app/controllers/concerns/renders_member_access.rb:14:in `preload_max_member_access_for_collection'
        backtrace.first.split(/:\d+:in /)
      end

      def duration_histogram
        @duration_histogram ||= Gitlab::Metrics.histogram(
          :performance_bar_stats_sql_query_duration,
          'SQL query duration gathered by performance bar'
        )
      end

      def frequency_histogram
        @frequency_histogram ||= Gitlab::Metrics.histogram(
          :performance_bar_stats_sql_query_frequency,
          'How many times an SQL query is called per one request'
        )
      end
    end
  end
end
