# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting a list of compliance frameworks for a root namespace' do
  include GraphqlHelpers

  let_it_be(:namespace) { create(:namespace) }
  let_it_be(:compliance_framework_1) { create(:compliance_framework, namespace: namespace, name: 'Test1') }
  let_it_be(:compliance_framework_2) { create(:compliance_framework, namespace: namespace, name: 'Test2') }

  let_it_be(:query) do
    graphql_query_for(
      :namespace, { full_path: namespace.full_path }, 'complianceFrameworks { nodes { id name description color } }'
    )
  end

  context 'when authenticated as the namespace owner' do
    let(:current_user) { namespace.owner }

    it 'returns the groups compliance frameworks' do
      post_graphql(query, current_user: current_user)

      expect(graphql_data.dig('namespace', 'complianceFrameworks', 'nodes')).not_to be_empty
    end
  end

  context 'when authenticated as a different user' do
    let(:current_user) { build(:user) }

    it "does not return the namespaces compliance frameworks" do
      post_graphql(query, current_user: current_user)

      expect(graphql_data.dig('namespace', 'complianceFrameworks', 'nodes')).to be_nil
    end
  end

  context 'when not authenticated' do
    it "does not return the namespace's compliance frameworks" do
      post_graphql(query)

      expect(graphql_data.dig('namespace', 'complianceFrameworks', 'nodes')).to be_nil
    end
  end
end
