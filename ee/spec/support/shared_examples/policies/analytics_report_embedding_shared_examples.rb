# frozen_string_literal: true

RSpec.shared_examples 'analytics report embedding' do
  let(:current_user) { nil }

  context 'when subject is not public' do
    before do
      allow(subject.subject).to receive(:public?).and_return(false)
    end

    it { is_expected.to be_disallowed(:view_embedded_analytics_report) }
  end

  context 'when subject is public' do
    before do
      allow(subject.subject).to receive(:public?).and_return(true)
    end

    it { is_expected.to be_allowed(:view_embedded_analytics_report) }
  end
end
