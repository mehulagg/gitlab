# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UsagePing::TrackService do
  subject(:service) { described_class.new(container: event, current_user: user) }
  let(:event) { 'static_site_editor_commit' }
  let_it_be(:user) { create(:user) }

  describe '#execute' do
    subject { service.execute }

    it 'returns a success status' do
      expect(subject.status).to eq(:success)
    end

    it 'tracks a usage ping event' do
      expect(Gitlab::UsageDataCounters::StaticSiteEditorCounter).to receive(:increment_commits_count)

      subject
    end

    context 'when event is not supported' do
      let(:event) { 'unknown' }

      it 'returns an error status' do
        expect(subject.status).to eq(:error)
      end

      it 'populates message' do
        expect(subject.message).to eq('Unsupported event')
      end
    end
  end
end
