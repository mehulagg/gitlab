# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dashboard::Environments::ListService do
  describe '#execute' do
    def setup
      user = create(:user)
      project = create(:project, :repository)
      project.add_developer(user)
      user.update!(ops_dashboard_projects: [project])

      [user, project]
    end

    before do
      stub_licensed_features(operations_dashboard: true)
    end

    it 'returns a list of projects' do
      user, project = setup

      projects_with_environments = described_class.new(user).execute

      expect(projects_with_environments).to eq([project])
    end

    it 'preloads only relevant ci_builds' do
      user, project = setup

      ci_build_a = create(:ci_build, project: project)
      ci_build_b = create(:ci_build, project: project)
      ci_build_c = create(:ci_build, project: project)

      environment_a = create(:environment, project: project)
      environment_b = create(:environment, project: project)

      create(:deployment, :success, project: project, environment: environment_a, deployable: ci_build_a)
      create(:deployment, :success, project: project, environment: environment_a, deployable: ci_build_b)
      create(:deployment, :success, project: project, environment: environment_b, deployable: ci_build_c)

      expect(CommitStatus).to receive(:instantiate)
        .with(a_hash_including("id" => ci_build_b.id), anything)
        .at_least(:once)
        .and_call_original

      expect(CommitStatus).to receive(:instantiate)
        .with(a_hash_including("id" => ci_build_c.id), anything)
        .at_least(:once)
        .and_call_original

      described_class.new(user).execute
    end

    context 'when unlicensed' do
      before do
        stub_licensed_features(operations_dashboard: false)
      end

      it 'returns an empty array' do
        user = create(:user)
        project = create(:project)
        project.add_developer(user)
        user.update!(ops_dashboard_projects: [project])

        projects_with_environments = described_class.new(user).execute

        expect(projects_with_environments).to eq([])
      end
    end
  end
end
