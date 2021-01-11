# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastScan, type: :model do
  subject { create(:dast_scan) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:dast_site_profile) }
    it { is_expected.to belong_to(:dast_scanner_profile) }
  end
end
