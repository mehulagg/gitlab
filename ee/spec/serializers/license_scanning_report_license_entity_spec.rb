# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LicenseScanningReportLicenseEntity do
  include LicenseScanningReportHelper

  let(:user) { build(:user) }
  let(:project) { build(:project, :repository) }
  let(:license) { create_license }
  let(:request) { double('request') }
  let(:entity) { described_class.new(license, request: request) }

  before do
    allow(request).to receive(:current_user).and_return(user)
    allow(request).to receive(:project).and_return(project)
  end

  describe '#as_json' do
    subject { entity.as_json }

    it 'emits the correct approval_status' do
      expect(subject[:classification][:approval_status]).to eq('unclassified')
    end

    it 'contains the correct dependencies' do
      expect(subject[:dependencies].count).to eq(2)
      expect(subject[:dependencies][0][:name]).to eq('Dependency1')
    end
  end
end
