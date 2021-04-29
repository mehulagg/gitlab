# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Email::Message::InProductMarketing do
  describe '.for' do
    subject { described_class.for(track) }

    context 'when track exists' do
      let(:track) { :create }

      it { is_expected.to eq(Gitlab::Email::Message::InProductMarketing::Create) }
    end

    context 'when track does not exist' do
      let(:track) { :non_existent }

      it 'raises error' do
        expect { subject }.to raise_error(described_class::UnknownTrackError)
      end
    end
  end
end
