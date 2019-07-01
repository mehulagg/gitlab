# frozen_string_literal: true

require 'spec_helper'

describe Branches::DivergingCommitCountsService do
  let(:project) { create(:project, :repository) }
  let(:repository) { project.repository }

  describe '#call' do
    let(:diverged_branch) { repository.find_branch('fix') }
    let(:root_ref_sha) { repository.raw_repository.commit(repository.root_ref).id }
    let(:diverged_branch_sha) { diverged_branch.dereferenced_target.sha }

    let(:service) { described_class.new(repository) }

    it 'returns the commit counts behind and ahead of default branch' do
      result = service.call(diverged_branch)

      expect(result).to eq(behind: 29, ahead: 2)
    end

    context 'when gitaly_count_diverging_commits_no_max is enabled' do
      before do
        stub_feature_flags(gitaly_count_diverging_commits_no_max: true)
      end

      it 'calls diverging_commit_count without max count' do
        expect(repository.raw_repository)
          .to receive(:diverging_commit_count)
          .with(root_ref_sha, diverged_branch_sha)
          .and_return([29, 2])

        service.call(diverged_branch)
      end
    end

    context 'when gitaly_count_diverging_commits_no_max is disabled' do
      before do
        stub_feature_flags(gitaly_count_diverging_commits_no_max: false)
      end

      it 'calls diverging_commit_count with max count' do
        expect(repository.raw_repository)
          .to receive(:diverging_commit_count)
          .with(root_ref_sha, diverged_branch_sha, max_count: Repository::MAX_DIVERGING_COUNT)
          .and_return([29, 2])

        service.call(diverged_branch)
      end
    end
  end
end
