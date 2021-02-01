# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::InstanceSecurityDashboardResolver do
  include GraphqlHelpers

  describe '#resolve' do
    subject(:instance_security_dashboard) { resolve(described_class, ctx: { current_user: current_user }) }

    let_it_be(:current_user) { create(:user) }

    it { is_expected.to be_a(InstanceSecurityDashboard) }
  end
end
