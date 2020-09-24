# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ManagedLicenseEntity do
  let(:software_license_policy) { create(:software_license_policy) }
  let(:entity) { described_class.new(software_license_policy) }

  describe '#as_json' do
    subject { entity.as_json }

    it 'contains required fields' do
      expect(subject).to include(:id, :name, :approval_status)
    end

    describe "#approval_status" do
      where(:classification, :approval_status) do
        [
          %w[allowed approved],
          %w[denied blacklisted]
        ]
      end

      with_them do
        let(:software_license_policy) { build(:software_license_policy, classification: classification) }

        it { expect(subject[:approval_status]).to eql(approval_status) }
      end
    end
  end
end
