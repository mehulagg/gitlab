# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BoardLabel do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:board) }
    it { is_expected.to validate_presence_of(:label) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:label) }
  end
end
