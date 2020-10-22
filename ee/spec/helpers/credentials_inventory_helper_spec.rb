# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CredentialsInventoryHelper do
  let(:filter) { nil }

  before do
    controller.params[:filter] = filter
  end

  describe '#credentials_inventory_feature_available?' do
    subject { credentials_inventory_feature_available? }

    context 'when credentials inventory feature is enabled' do
      before do
        stub_licensed_features(credentials_inventory: true)
      end

      it { is_expected.to be_truthy }
    end

    context 'when credentials inventory feature is disabled' do
      before do
        stub_licensed_features(credentials_inventory: false)
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#show_ssh_keys?' do
    subject { show_ssh_keys? }

    context 'when filtering by ssh_keys' do
      let(:filter) { 'ssh_keys' }

      it { is_expected.to be_truthy }
    end

    context 'when filtering by a different, existent credential type' do
      let(:filter) { 'personal_access_tokens' }

      it { is_expected.to be_falsey }
    end

    context 'when filtering by a different, non-existent credential type' do
      let(:filter) { 'non-existent-filter' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#show_personal_access_tokens?' do
    subject { show_personal_access_tokens? }

    context 'when filtering by personal_access_tokens' do
      let(:filter) { 'personal_access_tokens' }

      it { is_expected.to be_truthy }
    end

    context 'when filtering by a different, existent credential type' do
      let(:filter) { 'ssh_keys' }

      it { is_expected.to be_falsey }
    end

    context 'when filtering by a different, non-existent credential type' do
      let(:filter) { 'non-existent-filter' }

      it { is_expected.to be_truthy }
    end
  end
end
