# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Service do
  describe 'Available services' do
    let(:ee_services) do
      %w(
        github
        jenkins
      )
    end

    it { expect(described_class.available_services_names).to include(*ee_services) }
  end
end
