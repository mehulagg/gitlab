# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Admin::CloudLicenses::LicensesResolver do
  include GraphqlHelpers

  let_it_be(:admin) { create(:admin) }
  let_it_be(:license) { create(:license) }

  specify do
    expect(described_class).to have_nullable_graphql_type(::Types::Admin::CloudLicenses::LicenseType.connection_type)
  end

  def resolve_licenses(current_user: admin)
    resolve(described_class, ctx: { current_user: current_user })
  end

  describe '#resolve' do
    subject(:result) { resolve_licenses }

    before do
      stub_application_setting(cloud_license_enabled: true)
    end

    context 'when application setting for cloud license is disabled' do
      it 'raises error' do
        stub_application_setting(cloud_license_enabled: false)

        expect(result).to be_nil
      end
    end

    context 'when current user is not an admin' do
      it 'raises error' do
        unauthorized_user = create(:user)

        expect do
          resolve_licenses(current_user: unauthorized_user)
        end.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when there is no current license' do
      it 'returns the current license' do
        License.current.destroy!

        expect(result).to be_nil
      end
    end

    it 'returns the current license' do
      expect(result).to eq(license)
    end
  end
end
