# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LicenseScanningReportsComparerEntity do
  include LicenseScanningReportHelper

  let(:user) { build(:user) }
  let(:project) { build(:project, :repository) }
  let(:request) { double('request') }
  let(:comparer) { create_comparer }
  let(:entity) { described_class.new(comparer, request: request) }

  before do
    allow(request).to receive(:current_user).and_return(user)
    allow(request).to receive(:project).and_return(project)
  end

  describe '#as_json' do
    subject { entity.as_json }

    it 'contains the new existing and removed license lists' do
      expect(subject).to have_key(:new_licenses)
      expect(subject).to have_key(:existing_licenses)
      expect(subject).to have_key(:removed_licenses)

      expect(subject[:new_licenses][0][:name]).to eq('License4')
      expect(subject[:existing_licenses].count).to be(2)
      expect(subject[:removed_licenses][0][:name]).to eq('License1')
    end
  end
end
