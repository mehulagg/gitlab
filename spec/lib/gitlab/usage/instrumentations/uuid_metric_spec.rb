# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::Instrumentations::UuidMetric do
  it 'has correct uuid value' do
    expect(subject.value).to eq(Gitlab::CurrentSettings.uuid)
  end
end
