# frozen_string_literal: true

RSpec.shared_context 'stubbed service ping metrics definitions' do
  include UsageDataHelpers

  let(:metrics_definitions) { standard_metrics + subscription_metrics + operational_metrics + optional_metrics }
  let(:standard_metrics) do
    [
      metric_attributes('uuid', 'GitLab instance unique identifier', "Standard")
    ]
  end

  let(:operational_metrics) do
    [
      metric_attributes('counts.merge_requests', 'Count of the number of merge requests', "Operational"),
      metric_attributes('counts.todos', 'Count of todos created', "Operational")
    ]
  end

  let(:optional_metrics) do
    [
      metric_attributes('counts.boards', 'Count of Boards created', "Optional")
    ]
  end

  before do
    stub_usage_data_connections
    stub_object_store_settings

    allow(Gitlab::Usage::MetricDefinition).to(
      receive(:definitions)
        .and_return(metrics_definitions.to_h { |definition| [definition['key_path'], double(attributes: definition)] })
    )
  end

  def metric_attributes(key_path, description, category)
    {
      'key_path' => key_path,
      'description' => description,
      'data_category' => category
    }
  end
end
