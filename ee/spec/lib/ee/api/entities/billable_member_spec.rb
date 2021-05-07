# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::API::Entities::BillableMember do
  let(:last_activity_on) { Date.today }
  let(:public_email) { nil }
  let(:member) { build(:user, public_email: public_email, email: 'private@email.com', last_activity_on: last_activity_on) }

  subject(:entity_representation) { described_class.new(member).as_json }

  it 'returns the last_activity_on attribute' do
    expect(entity_representation[:last_activity_on]).to eq last_activity_on
  end

  context 'when the user has a public_email assigned' do
    let(:public_email) { 'public@email.com' }

    it 'exposes public_email instead of email' do
      aggregate_failures do
        expect(entity_representation.keys).to include(:email)
        expect(entity_representation[:email]).to eq public_email
        expect(entity_representation[:email]).not_to eq member.email
      end
    end
  end

  context 'when the user has no public_email assigned' do
    let(:public_email) { nil }

    it 'returns a nil value for email' do
      aggregate_failures do
        expect(entity_representation.keys).to include(:email)
        expect(entity_representation[:email]).to be nil
      end
    end
  end
end
