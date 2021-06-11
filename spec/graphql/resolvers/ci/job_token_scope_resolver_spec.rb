# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ci::JobTokenScopeResolver do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }

  specify do
    expect(described_class).to have_nullable_graphql_type(::Types::ProjectType.connection_type)
  end

  def resolve_ci_job_token_allow_list_projects(project, args)
    resolve(described_class, obj: project, args: args)
  end

  describe '#resolve' do
    it 'returns nil when scope is not enabled' do
      allow(project).to receive(:job_token_scope_enabled?).and_return(false)

      result = resolve_ci_job_token_allow_list_projects(project, {})

      expect(result).to eq(nil)
    end

    it 'returns the same project in the allow list of projects for the Ci Job Token' do
      result = resolve_ci_job_token_allow_list_projects(project, {})

      expect(result).to contain_exactly(project)
    end

    context 'when another projects gets added to the allow list' do
      let!(:link) { create(:ci_job_token_project_scope_link, source_project: project) }

      it 'returns the same project and another project that is on the allow list' do
        result = resolve_ci_job_token_allow_list_projects(project, {})

        expect(result).to contain_exactly(project, link.target_project)
      end
    end
  end
end
