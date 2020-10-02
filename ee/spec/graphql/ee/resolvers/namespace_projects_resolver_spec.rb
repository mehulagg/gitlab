# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::NamespaceProjectsResolver do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }

  context "with a group" do
    let_it_be(:group) { create(:group) }
    let_it_be(:project_1) { create_project(repository_size_limit: nil, repository_size: 10) }
    let_it_be(:project_2) { create_project(repository_size_limit: 50, repository_size: 80) }
    let_it_be(:project_3) { create_project(repository_size_limit: 10, repository_size: 15) }

    before do
      project_1.add_developer(current_user)
      project_2.add_developer(current_user)
      project_3.add_developer(current_user)

      create(:vulnerability, project: project_1)
      create(:vulnerability, project: project_3)
    end

    describe '#resolve' do
      subject(:projects) { resolve_projects(has_vulnerabilities) }

      context 'when the `has_vulnerabilities` parameter is not truthy' do
        let(:has_vulnerabilities) { false }

        it { is_expected.to eq([project_2, project_3, project_1]) }
      end

      context 'when the `has_vulnerabilities` parameter is truthy' do
        let(:has_vulnerabilities) { true }

        it { is_expected.to eq([project_3, project_1]) }
      end
    end
  end

  def create_project(repository_size_limit:, repository_size:)
    create(:project,
      namespace: group,
      repository_size_limit: repository_size_limit,
      statistics: create(:project_statistics, repository_size: repository_size)
    )
  end

  def resolve_projects(has_vulnerabilities)
    args = {
      include_subgroups: false,
      has_vulnerabilities: has_vulnerabilities,
      sort: :similarity,
      search: nil
    }

    resolve(described_class, obj: group, args: args, ctx: { current_user: current_user })
  end
end
