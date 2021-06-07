# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::API::Entities::Ci::Minutes::AdditionalPack do
  let(:pack) { build(:ci_minutes_additional_pack) }

  subject(:entity_representation) { described_class.new(pack).as_json }

  context 'attributes' do
    it { expect(entity_representation[:expires_at]).to eq pack.expires_at }
    it { expect(entity_representation[:namespace_id]).to eq pack.namespace_id }
    it { expect(entity_representation[:number_of_minutes]).to eq pack.number_of_minutes }
    it { expect(entity_representation[:purchase_xid]).to eq pack.purchase_xid }
  end
end
