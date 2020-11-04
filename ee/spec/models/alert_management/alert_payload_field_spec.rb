# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::AlertPayloadField do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:path) }
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:type) }
  end
end
