# frozen_string_literal: true

RSpec.shared_examples 'assigning an already assigned user' do |is_multiline|
  before do
    target.assignees = [assignee]
  end

  it 'adds multiple assignees from the list' do
    _, update_params, message = service.execute(note)

    expected_message = is_multiline ? "Assigned @#{user.username}. Assigned @#{assignee.username}." : "Assigned @#{assignee.username} and @#{user.username}."
    expect(message).to eq(expected_message)
    expect { service.apply_updates(update_params, note) }.not_to raise_error
  end
end
