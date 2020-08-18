# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clusters::Agent do
  subject { create(:cluster_agent) }

  it { is_expected.to belong_to(:project).class_name('::Project') }
  it { is_expected.to have_many(:agent_tokens).class_name('Clusters::AgentToken') }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(63) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:project_id) }

  describe 'validation' do
    describe 'name validation' do
      it 'rejects names that do not conform to RFC 1123', :aggregate_failures do
        %w[Agent agentA agentAagain gent- -agent agent.a agent/a agent>a].each do |name|
          agent = build(:cluster_agent, name: name)

          expect(agent).not_to be_valid
          expect(agent.errors[:name]).to eq(["can contain only lowercase letters, digits, and '-', but cannot start or end with '-'"])
        end
      end

      it 'accepts valid names', :aggregate_failures do
        %w[agent agent123 agent-123].each do |name|
          agent = build(:cluster_agent, name: name)

          expect(agent).to be_valid
        end
      end
    end

    describe 'config file validation' do
      context 'when project default branch is missing' do
        let(:empty_project) { create(:project) }
        let(:subject) { ::Clusters::Agent.new(name: 'bad-project', project: empty_project) }

        it 'fails to create due to missing root_ref', :aggregate_failures do
          expect(subject.save).to be_falsey
          expect(subject.errors[:configuration_setup]).to eq(["The file 'agents/#{subject.name}/config.yaml' is missing from this repository"])
        end
      end

      context 'when project config file is missing' do
        before do
          subject.project.repository.delete_file(
            subject.project.creator,
            "agents/#{subject.name}/config.yaml",
            message: 'Remove config file',
            branch_name: subject.project.repository.root_ref
          )
        end

        it 'fails to update due to missing config file', :aggregate_failures do
          expect(subject.save).to be_falsey
          expect(subject.errors[:configuration_setup]).to eq(["The file 'agents/#{subject.name}/config.yaml' is missing from this repository"])
        end
      end
    end
  end
end
