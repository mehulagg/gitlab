# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Pages::Settings do
  let(:settings) { double(path: 'the path', local_store: 'local store') }

  describe '#path' do
    subject { described_class.new(settings).path }

    it { is_expected.to eq('the path') }

    context 'when running under a web server outside of test mode' do
      before do
        allow(::Gitlab::Runtime).to receive(:test_suite?).and_return(false)
        allow(::Gitlab::Runtime).to receive(:web_server?).and_return(true)
      end

      it 'raises a DiskAccessDenied exception' do
        expect { subject }.to raise_error(described_class::DiskAccessDenied)
      end
    end
  end

  describe '#local_store' do
    subject(:local_store) { described_class.new(settings).local_store }

    it 'is an instance of Gitlab::Pages::LocalStore' do
      expect(local_store).to be_a(Gitlab::Pages::LocalStore)
    end
  end
end
