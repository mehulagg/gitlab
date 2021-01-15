# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::DastProfileType do
  include GraphqlHelpers

  let_it_be(:object) { create(:dast_profile) }
  let_it_be(:fields) { %i[id name description dastSiteProfile dastScannerProfile editPath] }

  specify { expect(described_class.graphql_name).to eq('DastProfile') }
  specify { expect(described_class).to require_graphql_authorizations(:create_on_demand_dast_scan) }

  it { expect(described_class).to have_graphql_fields(fields) }

  describe 'editPath field' do
    it 'correctly renders the field' do
      expected_result = Rails.application.routes.url_helpers.edit_project_on_demand_scan_path(object.project, object)

      expect(resolve_field(:edit_path, object)).to eq(expected_result)
    end
  end
end
