# frozen_string_literal: true

module Gitlab
  module Prometheus
    module Queries
      class PacketFlowQuery < BaseQuery
        FORWARDED = "FORWARDED"
        DROPPED   = "DROPPED"

        def query(namespace, interval = "hour", from = 1.day.ago.to_s, to = Time.now.to_s)
          from = Time.parse(from)
          to = Time.parse(to)
          rate_interval = to_prometheus_interval(interval)
          increase_interval = (to - from).to_i

          rate_query = sum_by_verdict(
            rate_query(%{destination="#{namespace}"}, rate_interval),
            rate_query(%{source="#{namespace}"}, rate_interval)
          )
          total_query = sum_by_verdict(
            increase_query(%{destination="#{namespace}"}, increase_interval),
            increase_query(%{source="#{namespace}"}, increase_interval)
          )

          {
            ops_rate:  transform_rate_result(client_query_range(rate_query, start_time: from, end_time: to)),
            ops_total: transform_sum_result(client_query(total_query, time: to))
          }
        end

        private

        def sum_by_verdict(vec1, vec2)
          %{sum by(verdict) (#{vec1} or on(source,destination,verdict) #{vec2})}
        end

        def rate_query(selector, interval)
          %{rate(hubble_flows_processed_total{#{selector}}[#{interval}])}
        end

        def increase_query(selector, interval)
          %{increase(hubble_flows_processed_total{#{selector}}[#{interval}s])}
        end

        # Returns rate of packets and dropped packets from a range vector:
        # [
        #  {"metric"=>{"verdict"=>"FORWARDED"}, "values"=>[[1582231596.64, "73772.43143284984"]]},
        #  {"metric"=>{"verdict"=>"DROPPED"}, "values"=>[[1582231596.64, "5.002730665588791"]]}
        # ]
        def transform_rate_result(vector)
          values = vector.each_with_object({ DROPPED => [], FORWARDED => [] }) do |val, acc|
            acc[val["metric"].first.second] = val["values"].map { |item| [item.first, item.last.to_f] }
          end

          forwards = values[FORWARDED]
          drops = values[DROPPED]

          { total: sum_vectors(drops, forwards), drops: drops }
        end

        # Returns total amount of packets and dropped packets from an instant vector:
        # [
        #  {"metric"=>{"verdict"=>"FORWARDED"}, "value"=>[1582231596.64, "73772.43143284984"]},
        #  {"metric"=>{"verdict"=>"DROPPED"}, "value"=>[1582231596.64, "5.002730665588791"]}
        # ]
        def transform_sum_result(vector)
          values = vector.each_with_object({ DROPPED => 0, FORWARDED => 0 }) do |val, acc|
            acc[val["metric"].first.second] = val["value"].last.to_i
          end

          forwards = values[FORWARDED]
          drops = values[DROPPED]

          { total: forwards + drops, drops: drops }
        end

        def to_prometheus_interval(interval)
          case interval
          when "hour" then "1h"
          when "day" then "1d"
          else
            "5m"
          end
        end

        # Sums 2 vectors in format [[ts1, val1 + val2]]
        # Expects vectors to be equal length. One of the vectors can be nil
        def sum_vectors(vec1, vec2)
          return vec1 if vec2.empty?
          return vec2 if vec1.empty?

          acc = []
          vec1.zip(vec2) { |v1, v2| acc << [v1.first, v1.second + v2.second] }
          acc
        end
      end
    end
  end
end
