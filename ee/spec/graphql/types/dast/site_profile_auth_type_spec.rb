# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Dast::SiteProfileAuthType do
  specify { expect(described_class.graphql_name).to eq('DastSiteProfileAuth') }
  specify { expect(described_class).to require_graphql_authorizations(:read_on_demand_scans) }

  it { expect(described_class).to have_graphql_fields(%w[enabled url usernameField passwordField username password]) }
end
