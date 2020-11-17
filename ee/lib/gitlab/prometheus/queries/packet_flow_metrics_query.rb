# frozen_string_literal: true

module Gitlab::Prometheus::Queries
  class PacketFlowMetricsQuery < BaseQuery
    def query
      transform_sum_result(client_query(sum_by_verdict))
    end

    private

    def sum_by_verdict
      %{sum by(verdict) (increase(hubble_flows_processed_total[1w]))}
    end

    # Returns the number of forwarded and dropped packets from an instant vector:
    # [
    #  {"metric"=>{"verdict"=>"FORWARDED"}, "value"=>[1582231596.64, "73772.43143284984"]},
    #  {"metric"=>{"verdict"=>"DROPPED"}, "value"=>[1582231596.64, "5.002730665588791"]}
    # ]
    def transform_sum_result(vector)
      values = vector.each_with_object({ "DROPPED" => 0, "FORWARDED" => 0 }) do |val, acc|
        acc[val["metric"].first.second] = val["value"].last.to_i
      end

      { forwards: values["FORWARDED"], drops: values["DROPPED"] }
    end
  end
end
