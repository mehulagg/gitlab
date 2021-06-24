# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::CiConfiguration::DependencyScanningCreateService, :snowplow do
  subject(:result) { described_class.new(project, user, params).execute }

  let(:branch_name) { 'set-dependency-scanning-config-1' }

  let(:non_empty_params) do
    { 'stage' => 'security',
      'SECURE_LOG_LEVEL' => 'debug',
      'SECURE_ANALYZERS_PREFIX' => 'new_registry',
      'DS_EXCLUDED_PATHS' => 'spec,docs' }
  end

  let(:snowplow_event) do
    {
      category: 'Security::CiConfiguration::DependencyScanningCreateService',
      action: 'create',
      label: 'false'
    }
  end

  include_examples 'services security ci configuration create service'
end
