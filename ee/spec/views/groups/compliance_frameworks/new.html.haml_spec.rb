# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'groups/compliance_frameworks/new.html.haml' do
  let_it_be(:group) { build(:group) }

  before do
    assign(:group, group)
  end

  it 'shows the compliance frameworks form', :aggregate_failures do
    render

    expect(rendered).to have_content('New Compliance Framework')
    expect(rendered).to have_css('#js-compliance-frameworks-form')
  end
end
