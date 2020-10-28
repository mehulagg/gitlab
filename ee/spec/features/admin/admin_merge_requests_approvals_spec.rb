# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin interacts with merge requests approvals settings' do
  include StubENV

  let_it_be(:hippa) { ComplianceManagement::Framework::DEFAULT_FRAMEWORKS_BY_IDENTIFIER[:hipaa] }
  let_it_be(:application_settings) { create(:application_setting, compliance_frameworks: [hippa.id]) }
  let_it_be(:user) { create(:admin) }

  before do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    allow(License).to receive(:feature_available?).and_return(true)

    sign_in(user)
    visit(admin_push_rule_path)
  end

  it 'updates compliance frameworks' do
    page.within('.merge-request-approval-settings') do
      check 'SOC 2'
      click_button('Save changes')
    end

    visit(admin_push_rule_path)

    expect(page.find_field('SOC 2')).to be_checked
  end

  it 'unsets all compliance frameworks' do
    checkbox_selector = 'input[name="application_setting[compliance_frameworks][]"]'

    page.within('.merge-request-approval-settings') do
      page.all(checkbox_selector).each { |checkbox| checkbox.set(false) }

      click_button('Save changes')
    end

    visit(admin_push_rule_path)

    expect(page.all(checkbox_selector).map(&:checked?)).to all(be_falsey)
  end
end
