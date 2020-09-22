# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImport, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:source_type) }
    it { is_expected.to define_enum_for(:source_type).with_values(%i[gitlab]) }
  end
end
