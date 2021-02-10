# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::API::Entities::Scim::Emails do
  let(:user) { build(:user) }
  let(:identity) { build(:group_saml_identity, user: user) }

  let(:entity) do
    described_class.new(user)
  end

  subject { entity.as_json }

  it 'contains the email' do
    expect(subject[:value]).to eq(user.email)
  end

  it 'contains the type' do
    expect(subject[:type]).to eq('work')
  end

  it 'contains the email' do
    expect(subject[:primary]).to be true
  end
end
