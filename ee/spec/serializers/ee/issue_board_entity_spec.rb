# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssueBoardEntity do
  let_it_be(:project) { create(:project) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:user) { create(:user) }

  let(:request) { double('request', current_user: user) }
  let(:blocked_ids) { [] }

  subject { described_class.new(issue.reload, request: request, blocked_issue_ids: blocked_ids).as_json }

  describe '#weight' do
    it 'has `weight` attribute' do
      expect(subject).to include(:weight)
    end

    context 'when project does not support issue weights' do
      before do
        stub_licensed_features(issue_weights: false)
      end

      it 'does not have `weight` attribute' do
        expect(subject).not_to include(:weight)
      end
    end
  end

  describe '#blocked' do
    it 'the issue is not blocked by default' do
      expect(subject[:blocked]).to be_falsey
    end

    context 'when blocked_issue_ids contains the issue id' do
      let(:blocked_ids) { [issue.id] }

      it 'the issue is blocked' do
        expect(subject[:blocked]).to be_truthy
      end
    end

    context 'when blocked_issue_ids is not set' do
      let(:blocked_ids) { nil }

      it 'the issue is not blocked' do
        expect(subject[:blocked]).to be_falsey
      end
    end
  end
end
