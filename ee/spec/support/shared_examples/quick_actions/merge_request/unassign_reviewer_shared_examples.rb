# frozen_string_literal: true

RSpec.shared_examples 'unassigning one or more reviewers' do |example|
  before do
    target.reviewers = [reviewer]
  end

  it 'removes multiple reviewers from the list' do
    _, update_params, message = service.execute(note)

    expected_message = example[:multiline] ? "Removed reviewer @#{reviewer.username}. Removed reviewer @#{user.username}." : "Removed reviewers @#{user.username} and @#{reviewer.username}."

    expect(update_params[:reviewer_ids]).to match_array([])
    expect(message).to eq(expected_message)
    expect { service.apply_updates(update_params, note) }.not_to raise_error
  end
end
