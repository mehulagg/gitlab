# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['AlertManagementPrometheusIntegration'] do
  specify { expect(described_class.graphql_name).to eq('AlertManagementPrometheusIntegration') }

  specify { expect(described_class).to require_graphql_authorizations(:admin_project) }
end
