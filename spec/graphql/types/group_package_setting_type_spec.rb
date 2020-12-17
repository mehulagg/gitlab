# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['GroupPackageSetting'] do
  specify { expect(described_class.graphql_name).to eq('GroupPackageSetting') }

  specify { expect(described_class.description).to eq('The group level package registry settings') }

  specify { expect(described_class).to require_graphql_authorizations(:read_package_settings) }

  describe 'maven_duplicate_exception_regex field' do
    subject { described_class.fields['mavenDuplicateExceptionRegex'] }

    it 'returns untrusted regexp type' do
      is_expected.to have_graphql_type(Types::UntrustedRegexp)
    end
  end
end
