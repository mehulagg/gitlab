# frozen_string_literal: true

RSpec::Matchers.define :gitaly_request_with_path do |storage_name, relative_path|
  match do |actual|
    repository = actual.repository

    repository.storage_name == storage_name &&
      repository.relative_path == relative_path
  end
end

RSpec::Matchers.define :gitaly_request_with_params do |params|
  match do |actual|
    params.reduce(true) { |r, (key, val)| r && actual[key.to_s] == val }
  end
end

RSpec::Matchers.define :gitaly_kwargs_routed_to_primary do |expected|
  match do |actual|
    break false unless actual.is_a?(Hash)

    route_to_primary = actual.dig(:metadata, 'gitaly-route-repository-accessor-policy') == 'primary-only'

    expected == route_to_primary
  end
end
