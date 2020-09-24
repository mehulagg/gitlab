# frozen_string_literal: true

RSpec.shared_examples 'unassigning a not assigned user' do |is_multiline|
  before do
    target.assignees = [assignee]
  end

  it 'adds multiple assignees from the list' do
    _, update_params, message = service.execute(note)

    expected_message = is_multiline ? "Removed assignee @#{assignee.username}. Removed assignee @#{user.username}." : "Removed assignees @#{user.username} and @#{assignee.username}."

    expect(message).to eq(expected_message)
    expect { service.apply_updates(update_params, note) }.not_to raise_error
  end
end
