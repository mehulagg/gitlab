# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::ComplianceFramework::GroupSettingsHelper do
  let_it_be(:group) { build(:group) }

  before do
    assign(:group, group)
  end

  describe '#show_compliance_frameworks?' do
    using RSpec::Parameterized::TableSyntax

    where(:feature_flag_enabled, :license_feature_enabled, :result) do
      true | true | true
      false | true | false
      true | false | false
      false | false | false
    end

    with_them do
      before do
        stub_feature_flags(ff_custom_compliance_frameworks: feature_flag_enabled)
        stub_licensed_features(custom_compliance_frameworks: license_feature_enabled)
      end

      it 'returns the correct value' do
        expect(helper.show_compliance_frameworks?).to eql(result)
      end
    end
  end

  describe '#compliance_frameworks_list_data' do
    it 'returns the correct data' do
      expect(helper.compliance_frameworks_list_data).to contain_exactly(
        [:empty_state_svg_path, ActionController::Base.helpers.image_path('illustrations/welcome/ee_trial.svg')],
        [:group_path, group.full_path]
      )
    end
  end
end
