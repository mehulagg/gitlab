# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::API::Entities::Scim::NotFound do
  let(:entity) do
    described_class.new({})
  end

  subject { entity.as_json }

  it 'contains the schemas' do
    expect(subject[:schemas]).not_to be_empty
  end

  it 'contains the detail' do
    expect(subject[:detail]).to be_nil
  end

  it 'contains the status' do
    expect(subject[:status]).to eq(404)
  end
end
