# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssuableSla do
  describe 'associations' do
    it { is_expected.to belong_to(:issue).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:due_at) }
  end
end
