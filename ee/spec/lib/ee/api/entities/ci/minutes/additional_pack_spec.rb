# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::API::Entities::Ci::Minutes::AdditionalPack do
  it 'contains the correct attributes', :aggregate_failures do
    pack = build(:ci_minutes_additional_pack)

    entity = described_class.new(pack).as_json

    expect(entity[:expires_at]).to eq pack.expires_at
    expect(entity[:namespace_id]).to eq pack.namespace_id
    expect(entity[:number_of_minutes]).to eq pack.number_of_minutes
    expect(entity[:purchase_xid]).to eq pack.purchase_xid
  end
end
