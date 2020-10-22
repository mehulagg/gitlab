# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'compliance_management/compliance_framework/_compliance_framework_badge.html.haml' do
  let_it_be(:project) { build(:project, :with_compliance_framework) }

  before do
    allow(view).to receive(:show_compliance_framework_badge?).and_return(flag)
  end

  context 'when show' do
    let(:flag) { true }

    it 'renders a badge' do
      render('compliance_management/compliance_framework/compliance_framework_badge', project: project)

      expect(rendered).to have_selector('.compliance-framework-pill')
    end
  end

  context 'when not show' do
    let(:flag) { false }

    it 'does not render any badge' do
      render('compliance_management/compliance_framework/compliance_framework_badge', project: project)

      expect(rendered).not_to have_selector('.compliance-framework-pill')
    end
  end
end
