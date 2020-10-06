# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Security routing', 'routing' do
  describe 'root path' do
    include RSpec::Rails::RequestExampleGroup

    subject { get('/-/security') }

    it { is_expected.to redirect_to('/-/security/dashboard') }
  end

  describe '/-/security/dashboard' do
    subject { get('/-/security/dashboard') }

    it { is_expected.to route_to('security/dashboard#show') }
  end

  describe '/-/security/dashboard/settings' do
    subject { get('/-/security/dashboard/settings') }

    it { is_expected.to route_to('security/dashboard#settings') }
  end
end
