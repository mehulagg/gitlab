# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['DastScan'] do
  let_it_be(:fields) { %i[id name description dastSiteProfileId dastScannerProfileId editPath] }

  specify { expect(described_class.graphql_name).to eq('DastScan') }
  specify { expect(described_class).to require_graphql_authorizations(:create_on_demand_dast_scan) }

  it { expect(described_class).to have_graphql_fields(fields) }
end
