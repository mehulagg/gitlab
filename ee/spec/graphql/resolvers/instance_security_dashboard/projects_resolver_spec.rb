# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::InstanceSecurityDashboard::ProjectsResolver do
  include GraphqlHelpers

  describe '#resolve' do
    subject { resolve(described_class, obj: object, args: filters, ctx: { current_user: user }) }

    let_it_be(:project1) { create(:project, description: "Description for project1") }
    let_it_be(:project2) { create(:project, description: "Description for project2") }
    let_it_be(:user) { create(:user, security_dashboard_projects: [project1, project2]) }
    let_it_be(:filters) { {} }
    let_it_be(:object) { InstanceSecurityDashboard.new(user) }

    before_all do
      project1.add_developer(user)
      project2.add_developer(user)
    end

    context 'when provided object is InstanceSecurityDashboard' do
      it { is_expected.to match_array([project1, project2]) }
    end

    context 'when object is not provided' do
      let(:object) { nil }

      it { is_expected.to be_nil }
    end

    context 'when search filter is provided' do
      context 'search by name' do
        let(:filters) { { search: project1.name } }

        it 'returns matching project' do
          is_expected.to contain_exactly(project1)
        end
      end

      context 'search by path' do
        let(:filters) { { search: project1.path } }

        it 'returns matching project' do
          is_expected.to contain_exactly(project1)
        end
      end

      context 'search by description' do
        let(:filters) { { search: project1.description } }

        it 'returns matching project' do
          is_expected.to contain_exactly(project1)
        end
      end
    end
  end
end
