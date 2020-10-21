# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::Scan do
  describe 'associations' do
    it { is_expected.to belong_to(:build) }
    it { is_expected.to have_one(:pipeline).through(:build).class_name('Ci::Pipeline') }
    it { is_expected.to have_many(:findings) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:build_id) }
    it { is_expected.to validate_presence_of(:scan_type) }
  end

  describe '#project' do
    it { is_expected.to delegate_method(:project).to(:build) }
  end

  it_behaves_like 'having unique enum values'
end
