# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::API::Entities::BillableMember do
  let(:member) { build(:user, public_email: 'public@email.com', email: 'private@email.com') }

  subject(:entity_representation) { described_class.new(member).as_json }

  it 'exposes public_email instead of email' do
    aggregate_failures do
      expect(entity_representation.keys).to include(:email)
      expect(entity_representation[:email]).to eq member.public_email
      expect(entity_representation[:email]).not_to eq member.email
    end
  end
end
