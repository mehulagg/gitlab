# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::Instrumentations::TimeStampMetric do
  let_it_be(:current_time) { Time.current }

  before do
    allow(Time).to receive(:current).and_return(current_time)
  end

  it_behaves_like 'a correct instrumented metric value', { time_frame: 'none', data_source: 'ruby' } do
    let(:expected_value) { current_time }
  end
end
