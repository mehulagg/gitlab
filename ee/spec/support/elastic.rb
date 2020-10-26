# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:example, :elastic) do
    Elastic::ProcessBookkeepingService.clear_tracking!
    Gitlab::Elastic::Helper.default.delete_index
    Gitlab::Elastic::Helper.default.create_empty_index(options: { settings: { number_of_replicas: 0 } })
  end

  config.after(:example, :elastic) do
    Gitlab::Elastic::Helper.default.delete_index
    Elastic::ProcessBookkeepingService.clear_tracking!
  end

  config.include ElasticsearchHelpers, :elastic
end
