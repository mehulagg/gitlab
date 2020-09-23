# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Prometheus::Queries::AdditionalMetricsEnvironmentQuery do
  around do |example|
    Timecop.freeze { example.run }
  end

  include_examples 'additional custom metrics query' do
    let(:query_params) { [environment.id] }

    it 'queries using specific time' do
      expect(client).to receive(:query_range).with(anything, start_time: 8.hours.ago.to_f, end_time: Time.now.to_f)

      expect(query_result).not_to be_nil
    end
  end
end
