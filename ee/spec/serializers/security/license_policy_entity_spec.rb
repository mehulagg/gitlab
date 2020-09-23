# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::LicensePolicyEntity do
  let(:license) { build(:license_scanning_license, :mit).tap { |x| x.add_dependency('rails') } }
  let(:policy) { build(:software_license_policy, :allowed) }
  let(:entity) { described_class.new(SCA::LicensePolicy.new(license, policy)) }

  describe '#as_json' do
    subject { entity.as_json }

    specify { expect(subject[:name]).to eql(policy.name) }
    specify { expect(subject[:classification]).to eql({ id: policy.id, name: policy.name, approval_status: policy.approval_status }) }
    specify { expect(subject[:dependencies]).to match_array([{ name: 'rails' }]) }
    specify { expect(subject[:count]).to be(1) }
    specify { expect(subject[:url]).to eql(license.url) }
  end
end
