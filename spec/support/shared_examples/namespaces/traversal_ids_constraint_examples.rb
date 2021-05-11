# frozen_string_literal: true

RSpec.shared_examples 'traversal_ids constraint violation' do
  it 'triggers a check violation' do
    expect { subject }.to raise_error(ActiveRecord::StatementInvalid, /PG::CheckViolation/)
  end
end

RSpec.shared_examples 'traversal_ids without constraints' do
  it 'does not trigger a check violation' do
    expect { subject }.not_to raise_error
  end
end
