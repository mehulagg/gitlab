# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ForkNamespaceSerializer do
  it 'represents WebIdeTerminalEntity entities' do
    expect(described_class.entity_class).to eq(ForkNamespaceEntity)
  end
end
