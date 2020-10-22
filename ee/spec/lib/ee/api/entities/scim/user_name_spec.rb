# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::API::Entities::Scim::UserName do
  let(:user) { build(:user) }

  subject { described_class.new(user).as_json }

  it 'contains the name' do
    expect(subject[:formatted]).to eq(user.name)
  end

  it 'contains the first name' do
    expect(subject[:givenName]).to eq(user.first_name)
  end

  it 'contains the last name' do
    expect(subject[:familyName]).to eq(user.last_name)
  end
end
