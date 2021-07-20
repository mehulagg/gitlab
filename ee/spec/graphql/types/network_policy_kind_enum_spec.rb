# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['NetworkPolicyKind'] do
  it 'exposes all kinds of network policies' do
    expect(described_class.values.keys).to contain_exactly(*%w[CiliumNetworkPolicy NetworkPolicy])
  end
end
