# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SoftwareLicensePoliciesFinder do
  let(:project) { create(:project) }
  let(:software_license_policy) { create(:software_license_policy, project: project) }

  let(:user) do
    create(:user).tap do |u|
      project.add_maintainer(u)
    end
  end

  let(:finder) { described_class.new(user, project, params) }

  before do
    stub_licensed_features(license_scanning: true)
  end

  context 'searched by name' do
    let(:params) { { name: software_license_policy.name } }

    it 'by name finds the software license policy by name' do
      expect(finder.execute.take).to eq(software_license_policy)
    end
  end

  context 'searched by name_or_id' do
    context 'with a name' do
      let(:params) { { name_or_id: software_license_policy.name } }

      it 'by name_or_id finds the software license policy by name' do
        expect(finder.execute.take).to eq(software_license_policy)
      end
    end

    context 'with an id' do
      let(:params) { { name_or_id: software_license_policy.id.to_s } }

      it 'by name or id finds the software license policy by id' do
        expect(finder.execute.take).to eq(software_license_policy)
      end
    end
  end
end
