# frozen_string_literal: true

require "spec_helper"

RSpec.describe LicenseEntity do
  describe "#as_json" do
    subject { described_class.represent(license_policy).as_json }

    let(:license) { build(:license_scanning_license, :mit) }
    let(:license_policy) { ::SCA::LicensePolicy.new(license, software_policy) }
    let(:software_policy) { build(:software_license_policy) }
    let(:path) { 'some_path' }

    before do
      license.add_dependency('rails')
      allow(license.dependencies.first).to receive(:path).and_return(path)
    end

    it "produces the correct representation" do
      is_expected.to eq({
        id: license_policy.id,
        name: license_policy.name,
        url: license_policy.url,
        spdx_identifier: license_policy.spdx_identifier,
        classification: license_policy.classification,
        components: [{ name: 'rails', blob_path: path }]
      })
    end

    context "when the url is blank" do
      where(url: ['', nil])

      with_them do
        let(:license) { build(:license_scanning_license, :unknown) }

        it { expect(subject[:url]).to be_nil }
      end
    end
  end
end
