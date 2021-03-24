# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Admin::CloudLicenses::LicenseHistoryEntriesResolver do
  include GraphqlHelpers

  describe '#resolve' do
    subject(:result) { resolve_license_history_entries }

    let_it_be(:admin) { create(:admin) }
    let_it_be(:license) { create_current_license }

    def resolve_license_history_entries(current_user: admin)
      resolve(described_class, ctx: { current_user: current_user })
    end

    before do
      stub_application_setting(cloud_license_enabled: true)
    end

    context 'when application setting for cloud license is disabled', :enable_admin_mode do
      it 'raises error' do
        stub_application_setting(cloud_license_enabled: false)

        expect(result).to be_nil
      end
    end

    context 'when GitLab.com', :enable_admin_mode do
      it 'raises error' do
        allow(::Gitlab).to receive(:com?).and_return(true)

        expect(result).to be_nil
      end
    end

    context 'when current user is unauthorized' do
      it 'raises error' do
        unauthorized_user = create(:user)

        expect do
          resolve_license_history_entries(current_user: unauthorized_user)
        end.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    it 'returns the license history entries', :enable_admin_mode do
      expect(result).to include(license)
    end
  end
end
