# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::FlipperSessionHelper do
  describe '.flipper_session' do
    let(:session) { {} }

    before do
      allow(helper).to receive(:session).and_return(session)
    end

    subject { helper.flipper_session }

    context 'when a FlipperSession has not be previously set' do
      let(:predictable_id) { 'abc123' }

      before do
        allow_any_instance_of(FlipperSession).to receive(:generate_id).and_return(predictable_id)
      end

      it 'returns an instance of FlipperSession' do
        expect(subject).to be_instance_of(FlipperSession)
      end

      it 'sets a predictable FlipperSession id to session' do
        subject

        expect(session).to include(FlipperSession::SESSION_KEY => predictable_id)
      end
    end

    context 'when a FlipperSession has been previously set' do
      let(:predictable_id) { 'def456' }

      before do
        allow_any_instance_of(FlipperSession).to receive(:generate_id).and_return(predictable_id)
      end

      it 'returns a FlipperSession with the same ID' do
        # Cannot call subject as it will be cached and not trigger the logic a second time
        existing_flipper_session = helper.flipper_session

        expect(subject.id).to eq(existing_flipper_session.id)
      end
    end
  end
end
