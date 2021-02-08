# frozen_string_literal: true

RSpec.shared_examples 'iteration report group by label' do
  before do
    select 'Label', from: 'Group by'

    # Select label `label1` from the labels dropdown picker
    click_button 'Label'
    click_link label1.title
    send_keys(:escape)
  end

  it 'groups by label', :aggregate_failures do
    expect(page).to have_button('Collapse')
    expect(page).to have_css('.gl-label', text: label1.title)
    expect(page).to have_css('.gl-badge', text: 2)

    expect(page).to have_content(issue.title)
    expect(page).to have_content(assigned_issue.title)
    expect(page).to have_no_content(closed_issue.title)
    expect(page).to have_no_content(other_iteration_issue.title)
  end

  it 'shows ungrouped issues when `Group by: None` is selected again', :aggregate_failures do
    select 'None', from: 'Group by'

    expect(page).to have_no_button('Collapse')
    expect(page).to have_no_css('.gl-label', text: label1.title)
    expect(page).to have_no_css('.gl-badge', text: 2)

    expect(page).to have_content(issue.title)
    expect(page).to have_content(assigned_issue.title)
    expect(page).to have_content(closed_issue.title)
    expect(page).to have_no_content(other_iteration_issue.title)
  end
end
