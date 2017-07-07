require 'rails_helper'

feature 'User deletes snippet', feature: true do
  let(:user) { create(:user) }
  let(:content) { 'puts "test"' }
  let(:snippet) { create(:personal_snippet, :public, content: content, author: user) }

  before do
    sign_in(user)

    visit snippet_path(snippet)
  end

  it 'deletes the snippet' do
    first(:link, 'Delete').click

    expect(page).not_to have_content(snippet.title)
  end
end
