# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::API::Entities::Scim::User do
  let(:user) { build(:user) }
  let(:identity) { build(:group_saml_identity, user: user) }

  let(:entity) do
    described_class.new(identity)
  end

  subject { entity.as_json }

  it 'contains the schemas' do
    expect(subject[:schemas]).to eq(["urn:ietf:params:scim:schemas:core:2.0:User"])
  end

  it 'contains the extern UID' do
    expect(subject[:id]).to eq(identity.extern_uid)
  end

  it 'contains the active flag' do
    expect(subject[:active]).to be true
  end

  it 'contains the name' do
    expect(subject[:name][:formatted]).to eq(user.name)
  end

  it 'contains the first name' do
    expect(subject[:name][:givenName]).to eq(user.first_name)
  end

  it 'contains the last name' do
    expect(subject[:name][:familyName]).to eq(user.last_name)
  end

  it 'contains the email' do
    expect(subject[:emails].first[:value]).to eq(user.email)
  end

  it 'contains the username' do
    expect(subject[:userName]).to eq(user.username)
  end

  it 'contains the resource type' do
    expect(subject[:meta][:resourceType]).to eq('User')
  end

  context 'with a SCIM identity' do
    let(:identity) { build(:scim_identity, user: user) }

    it 'contains active false when the identity is not active' do
      identity.active = false

      expect(subject[:active]).to be false
    end
  end
end
