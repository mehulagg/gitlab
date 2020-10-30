# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::FindingLink do
  describe 'associations' do
    it { is_expected.to belong_to(:finding).class_name('Vulnerabilities::Finding') }
  end

  describe 'validations' do
    let!(:link) { create(:finding_link) }

    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:finding) }
  end
end
