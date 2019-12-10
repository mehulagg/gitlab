# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ApplicationSettingChecker::RuggedDetector do
  describe '#feature_enabled_any?' do
    subject { described_class.send(:feature_enabled_any?, feature_keys) }

    let(:feature1) { double('feature1', enabled?: true) }
    let(:feature2) { double('feature2', enabled?: true) }
    let(:feature3) { double('feature3', enabled?: false) }
    let(:feature4) { double('feature4', enabled?: false) }

    before do
      allow(Feature).to receive(:get).with(:feature_key_1).and_return(feature1)
      allow(Feature).to receive(:get).with(:feature_key_2).and_return(feature2)
      allow(Feature).to receive(:get).with(:feature_key_3).and_return(feature3)
      allow(Feature).to receive(:get).with(:feature_key_4).and_return(feature4)

      allow(Feature).to receive(:persisted?).with(feature1).and_return(true)
      allow(Feature).to receive(:persisted?).with(feature2).and_return(true)
      allow(Feature).to receive(:persisted?).with(feature3).and_return(true)
      allow(Feature).to receive(:persisted?).with(feature4).and_return(false)
    end

    context 'no feature keys given' do
      let(:feature_keys) { [] }

      it 'return false' do
        expect(subject).to be false
      end
    end

    context 'all features are enalbed' do
      let(:feature_keys) { [:feature_key_1, :feature_key_2] }

      it 'return true' do
        expect(subject).to be true
      end
    end

    context 'all features are not enalbed' do
      let(:feature_keys) { [:feature_key_3, :feature_key_4] }

      it 'return false' do
        expect(subject).to be false
      end
    end

    context 'some feature is enalbed' do
      let(:feature_keys) { [:feature_key_4, :feature_key_2] }

      it 'return true' do
        expect(subject).to be true
      end
    end
  end

  describe '#gitaly_can_use_disk_storage_any?' do
    subject { described_class.send(:gitaly_can_use_disk_storage_any?, storages) }

    before do
      allow(Gitlab::GitalyClient).to receive(:can_use_disk?).with('storage1').and_return(true)
      allow(Gitlab::GitalyClient).to receive(:can_use_disk?).with('storage2').and_return(true)
      allow(Gitlab::GitalyClient).to receive(:can_use_disk?).with('storage3').and_return(false)
      allow(Gitlab::GitalyClient).to receive(:can_use_disk?).with('storage4').and_return(false)
    end

    context 'no storage given' do
      let(:storages) { [] }

      it 'return false' do
        expect(subject).to be false
      end
    end

    context 'all storages can use disk' do
      let(:storages) { %w(storage1 storage2) }

      it 'return true' do
        expect(subject).to be true
      end
    end

    context 'all storages can not use disk' do
      let(:storages) { %w(storage3 storage4) }

      it 'return false' do
        expect(subject).to be false
      end
    end

    context 'some storage can  use disk' do
      let(:storages) { %w(storage3 storage1) }

      it 'return true' do
        expect(subject).to be true
      end
    end
  end
end
