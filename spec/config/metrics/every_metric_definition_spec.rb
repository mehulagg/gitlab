# frozen_string_literal: true

require 'spec_helper'

RSpec.configure do |rspec|
  rspec.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end

RSpec.describe 'Every metric definition' do
  let(:usage_ping) { Gitlab::UsageData.uncached_data }
  let(:usage_ping_key_paths) { parse_usage_ping_keys(usage_ping).flatten }
  let(:metric_files_key_paths) { Gitlab::Usage::MetricDefinition.definitions.keys }

  # Recursively traverse nested Hash of a generated Usage Ping to return an Array of key paths
  # in the dotted format used in metric definition YAML files, e.g.: 'count.category.metric_name'
  def parse_usage_ping_keys(object, key_path = [])
    if object.is_a? Hash
      object.each_with_object([]) do |(key, value), result|
        result.append parse_usage_ping_keys(value, key_path + [key])
      end
    else
      key_path.join('.')
    end
  end

  before do
    # Prevent Gitlab::Database::BatchCount from raising exceptions complaining about transactions
    allow(ActiveRecord::Base.connection).to receive(:transaction_open?).and_return(false)
  end

  it 'is included in the Usage Ping hash structure' do
    expect(metric_files_key_paths.sort).to match_array(usage_ping_key_paths.sort)
  end
end
