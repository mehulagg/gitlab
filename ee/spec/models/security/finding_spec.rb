# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::Finding do
  describe 'associations' do
    it { is_expected.to belong_to(:scan).required }
    it { is_expected.to belong_to(:scanner).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:project_fingerprint) }
    it { is_expected.to validate_length_of(:project_fingerprint).is_at_most(40) }
  end
end
