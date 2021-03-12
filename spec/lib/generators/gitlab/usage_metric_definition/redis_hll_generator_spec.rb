# frozen_string_literal: true

require 'generator_helper'

RSpec.describe Gitlab::UsageMetricDefinition::RedisHllGenerator do
  let(:category) { 'test_category' }
  let(:event) { 'i_test_event' }
  let(:args) { [category, event] }
  let(:temp_dir) { Dir.mktmpdir }

  # Interpolating to preload the class
  # See https://github.com/rspec/rspec-mocks/issues/1079
  before do
    stub_const("#{Gitlab::UsageMetricDefinitionGenerator}::TOP_LEVEL_DIR", temp_dir)
  end

  it 'creates metric definition files' do
    described_class.new(args).invoke_all

    weekly_metric_definition_path = Dir.glob(File.join(temp_dir, 'metrics/counts_7d/*i_test_event.yml')).first
    monthly_metric_definition_path = Dir.glob(File.join(temp_dir, 'metrics/counts_28d/*i_test_event.yml')).first

    expect(YAML.safe_load(File.read(weekly_metric_definition_path))).to include("key_path" => "redis_hll_counters.test_category.i_test_event")
    expect(YAML.safe_load(File.read(monthly_metric_definition_path))).to include("key_path" => "redis_hll_counters.test_category.i_test_event")
  end
end
