# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ci::CiJobTokenProjectsResolver do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }

  specify do
    expect(described_class).to have_nullable_graphql_type(::Types::ProjectType.connection_type)
  end

  def resolve_ci_job_token_allow_list_projects(project, args)
    resolve(described_class, obj: project, args: args)
  end

  describe '#resolve' do
    it 'returns the same project in the allowlist of projects for the Ci Job Token' do
      result = resolve_ci_job_token_allow_list_projects(project, {})

      expect(result).to contain_exactly(project)
    end
  end
end
