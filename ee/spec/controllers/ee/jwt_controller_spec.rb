# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::JwtController do
  describe 'SERVICES' do
    it 'includes the dependency proxy service' do
      expect(described_class::SERVICES.keys).to include('dependency_proxy')
    end
  end
end
