# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CloudLicensesHelper do
  describe '#cloud_licenses_view_data' do
    context 'when there is a current license' do
      it 'returns the data for the view' do
        custom_plan = 'custom plan'
        license = double('License', plan: custom_plan)
        allow(License).to receive(:current).and_return(license)

        expect(cloud_licenses_view_data).to eq({ current_plan_title: 'Custom Plan' })
      end
    end

    context 'when there is no current license' do
      it 'returns the data for the view' do
        allow(License).to receive(:current).and_return(nil)

        expect(cloud_licenses_view_data).to eq({ current_plan_title: 'Core' })
      end
    end
  end
end
