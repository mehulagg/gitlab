# frozen_string_literal: true

RSpec.shared_examples 'no Jira import data present' do
  it 'returns none' do
    expect(resolve_imports).to be_empty
  end
end

RSpec.shared_examples 'no Jira import access' do
  it 'returns nil' do
    expect(resolve_imports).to be_nil
  end
end
