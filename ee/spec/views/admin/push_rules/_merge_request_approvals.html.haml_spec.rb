# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin/push_rules/_merge_request_approvals' do
  let(:application_setting) { build(:application_setting) }

  before do
    assign(:application_setting, application_setting)

    stub_licensed_features(admin_merge_request_approvers_rules: true)
  end

  it 'shows settings form' do
    render

    expect(rendered).to have_content('Merge requests approvals')
  end

  context 'when show compliance merge request approval settings' do
    before do
      allow(view).to receive(:show_compliance_merge_request_approval_settings?).and_return(true)
    end

    it 'shows compliance framework content', :aggregate_failures do
      render

      expect(rendered).to have_content('Regulate approvals by authors/committers')
      expect(rendered).to have_content('Compliance frameworks')
    end
  end

  context 'when not show compliance merge request approval settings' do
    before do
      allow(view).to receive(:show_compliance_merge_request_approval_settings?).and_return(false)
    end

    it 'shows non-compliance framework content', :aggregate_failures do
      render

      expect(rendered).to have_content('Settings to prevent self-approval across all projects')
      expect(rendered).not_to have_content('Compliance frameworks')
    end
  end
end
