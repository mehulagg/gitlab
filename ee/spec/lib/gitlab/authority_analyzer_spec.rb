# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::AuthorityAnalyzer do
  describe '#calculate' do
    let(:project) { create(:project, :repository) }
    let(:author) { create(:user) }
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }
    let(:merge_request) { create(:merge_request, target_project: project, source_project: project) }
    let(:files) { %w(so many files) }

    let(:commits) do
      [
        double(:commit, author: author),
        double(:commit, author: user_a),
        double(:commit, author: user_a),
        double(:commit, author: user_b),
        double(:commit, author: author)
      ]
    end

    let(:approvers) { described_class.new(merge_request, author).calculate }

    it 'returns contributors in order, without skip_user' do
      stub_const('Gitlab::AuthorityAnalyzer::FILES_TO_CONSIDER', 1)

      expect(merge_request).to receive(:modified_paths).and_return(files)
      expect(merge_request.target_project.repository).to receive(:commits)
        .with(merge_request.target_branch, path: ['so'], limit: Gitlab::AuthorityAnalyzer::COMMITS_TO_CONSIDER)
        .and_return(commits)

      expect(approvers).to contain_exactly(user_a, user_b)
    end
  end
end
