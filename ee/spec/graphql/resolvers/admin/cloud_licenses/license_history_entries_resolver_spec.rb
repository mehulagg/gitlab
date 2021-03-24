# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Admin::CloudLicenses::LicenseHistoryEntriesResolver do
  include GraphqlHelpers

  let_it_be(:admin) { create(:admin) }
  let_it_be(:license) { create(:license) }

  specify do
    expect(described_class).to have_nullable_graphql_type(::Types::Admin::CloudLicenses::LicenseType.connection_type)
  end

  def resolve_licenses
    resolve(described_class, ctx: { current_user: admin })
  end

  describe '#resolve' do
    subject(:result) { resolve_licenses }

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
