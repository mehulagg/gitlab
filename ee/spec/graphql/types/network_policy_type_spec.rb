# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['NetworkPolicy'] do
  it { expect(described_class.graphql_name).to eq('NetworkPolicy') }

  it 'has the expected fields' do
    expect(described_class).to have_graphql_fields(
      :name,
      :kind,
      :namespace,
      :enabled,
      :from_auto_devops,
      :yaml,
      :updated_at,
      :environments
    )
  end

  describe '#environments' do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project, namespace: user.namespace) }
    let_it_be(:environment_1) { create(:environment, project: project) }
    let_it_be(:environment_2) { create(:environment, project: project) }
    let_it_be(:environment_3) { create(:environment, project: project) }

    let(:policy_1) { double(as_json: { creation_timestamp: Time.current.iso8601, project: project, environment_ids: [environment_1.id] }) }
    let(:policy_2) { double(as_json: { creation_timestamp: Time.current.iso8601, project: project, environment_ids: [environment_1.id, environment_2.id] }) }
    let(:service_response_single_environment) { double(success?: true, payload: [policy_1]) }
    let(:service_response_multiple_environments) { double(success?: true, payload: [policy_1, policy_2]) }

    let(:query) do
      %(
        query {
          project(fullPath: "#{project.full_path}") {
            networkPolicies {
              nodes {
                environments {
                  nodes {
                    id
                    name
                  }
                }
              }
            }
          }
        }
      )
    end

    it 'avoids N+1 database queries' do
      allow_next_instance_of(NetworkPolicies::ResourcesService) do |service|
        allow(service).to receive(:execute).and_return(service_response_single_environment)
      end

      control_count = ActiveRecord::QueryRecorder.new { GitlabSchema.execute(query, context: { current_user: user }) }.count

      allow_next_instance_of(NetworkPolicies::ResourcesService) do |service|
        allow(service).to receive(:execute).and_return(service_response_multiple_environments)
      end

      expect { GitlabSchema.execute(query, context: { current_user: user }) }.not_to exceed_query_limit(control_count)
    end
  end
end
