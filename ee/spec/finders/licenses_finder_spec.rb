# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LicensesFinder do
  let(:license) { create(:license) }

  let_it_be(:user) { create(:admin) }

  it 'returns a license by id' do
    expect(described_class.new(user, id: license.id).execute.take).to eq(license)
  end

  it 'returns a collection of licenses' do
    expect(described_class.new(user).execute).to contain_exactly(*License.all)
  end

  it 'returns empty relation if the license doesnt exist' do
    expect(described_class.new(user, id: 0).execute).to be_empty
  end

  it 'raises an error if the user is not an admin' do
    expect { described_class.new(create(:user), id: 0).execute }.to raise_error Gitlab::Access::AccessDeniedError
  end
end
