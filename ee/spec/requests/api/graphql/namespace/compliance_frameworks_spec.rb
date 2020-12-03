# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting a list of compliance frameworks for a root namespace' do
  include GraphqlHelpers

  let_it_be(:namespace) { create(:namespace) }
  let_it_be(:compliance_framework_1) { create(:compliance_framework, namespace: namespace, name: 'Test1') }
  let_it_be(:compliance_framework_2) { create(:compliance_framework, namespace: namespace, name: 'Test2') }
  let(:path) { %i[namespace compliance_frameworks nodes] }

  let!(:query) do
    graphql_query_for(
      :namespace, { full_path: namespace.full_path }, query_nodes(:compliance_frameworks)
    )
  end

  context 'when authenticated as the namespace owner' do
    let(:current_user) { namespace.owner }

    it 'returns the groups compliance frameworks' do
      post_graphql(query, current_user: current_user)

      expect(graphql_data_at(*path)).to contain_exactly(
        a_hash_including('id' => global_id_of(compliance_framework_1)),
        a_hash_including('id' => global_id_of(compliance_framework_2))
      )
    end

    context 'when querying a specific framework ID' do
      let(:query) do
        graphql_query_for(
          :namespace, { full_path: namespace.full_path }, query_nodes(:compliance_frameworks, nil, args: { id: global_id_of(compliance_framework_1) })
        )
      end

      it 'returns only a single compliance framework' do
        post_graphql(query, current_user: current_user)

        expect(graphql_data_at(:namespace, :complianceFrameworks, :nodes).size).to eq 1
        expect(graphql_data_at(:namespace, :complianceFrameworks, :nodes, 0, :id)).to eq global_id_of(compliance_framework_1)
      end
    end

    context 'when querying multiple namespaces' do
      let(:group) { create(:group) }
      let(:multiple_namespace_query) do
        <<~QUERY
          query {
            a: namespace(fullPath: "#{namespace.full_path}") {
              complianceFrameworks { nodes { id name } }
            }
            b: namespace(fullPath: "#{group.full_path}") {
              complianceFrameworks { nodes { id name } }
            }
          }
        QUERY
      end

      before do
        create(:compliance_framework, namespace: group)
        group.add_owner(current_user)
      end

      it 'avoids N+1 queries' do
        query_count = ActiveRecord::QueryRecorder.new { post_graphql(query, current_user: current_user) }.count

        expect { post_graphql(multiple_namespace_query, current_user: current_user) }.not_to exceed_query_limit(query_count + 4)
      end

      it 'responds with the expected list of compliance frameworks' do
        post_graphql(multiple_namespace_query, current_user: current_user)

        expect(graphql_data_at(:a, :complianceFrameworks, :nodes).map { |f| f['name'] }).to contain_exactly('Test1', 'Test2')
        expect(graphql_data_at(:b, :complianceFrameworks, :nodes).map { |f| f['name'] }).to contain_exactly('GDPR')
      end
    end

    context 'feature is disabled' do
      before do
        stub_feature_flags(ff_custom_compliance_frameworks: false)
      end

      it 'responds with error when querying a compliance framework' do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to contain_exactly(include('message' => "Field 'complianceFrameworks' doesn't exist on type 'Namespace'"))
      end
    end
  end

  context 'when authenticated as a different user' do
    let(:current_user) { build(:user) }

    it "does not return the namespaces compliance frameworks" do
      post_graphql(query, current_user: current_user)

      expect(graphql_data_at(*path)).to be_nil
    end
  end

  context 'when not authenticated' do
    it "does not return the namespace's compliance frameworks" do
      post_graphql(query)

      expect(graphql_data_at(*path)).to be_nil
    end
  end
end
