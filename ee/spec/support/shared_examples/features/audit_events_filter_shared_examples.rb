# frozen_string_literal: true

RSpec.shared_examples_for 'audit events date filter' do
  it 'shows only 2 days old events' do
    visit method(events_path).call(entity, created_after: 4.days.ago.to_date, created_before: 2.days.ago.to_date)

    find('.audit-log-table td', match: :first)

    expect(page).not_to have_content(audit_event_1.present.date)
    expect(page).to have_content(audit_event_2.present.date)
    expect(page).not_to have_content(audit_event_3.present.date)
  end

  it 'shows only yesterday events' do
    visit method(events_path).call(entity, created_after: 2.days.ago.to_date)

    find('.audit-log-table td', match: :first)

    expect(page).not_to have_content(audit_event_1.present.date)
    expect(page).not_to have_content(audit_event_2.present.date)
    expect(page).to have_content(audit_event_3.present.date)
  end

  it 'shows a message if provided date is invalid' do
    visit method(events_path).call(entity, created_after: '12-345-6789')

    expect(page).to have_content('Invalid date format. Please use UTC format as YYYY-MM-DD')
  end
end
