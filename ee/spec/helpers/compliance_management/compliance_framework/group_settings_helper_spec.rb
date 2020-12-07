# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::ComplianceFramework::GroupSettingsHelper do
  let_it_be(:group) { build(:group) }

  before do
    assign(:group, group)
  end

  describe '#compliance_framework_labels_list_data' do
    it 'returns the correct data' do
      expect(helper.compliance_framework_labels_list_data).to contain_exactly(
        [:empty_state_svg_path, ActionController::Base.helpers.image_path('illustrations/labels.svg')],
        [:group_path, group.full_path]
      )
    end
  end
end
