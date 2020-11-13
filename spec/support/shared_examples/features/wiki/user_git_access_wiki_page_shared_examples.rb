# frozen_string_literal: true

RSpec.shared_examples 'User views Git access wiki page' do
  before do
    sign_in(user)

    # Create a page, otherwise the sidebar won't be displayed
    create(:wiki_page, wiki: wiki, title: Wiki::HOMEPAGE)
  end

  it 'shows the correct clone URLs', :js do
    visit wiki_path(wiki)
    click_link 'Clone repository'

    expect(page).to have_text("Clone repository #{wiki.full_path}")
    expect(page).to have_css('#clone-dropdown', text: 'HTTP')
    expect(page).to have_field('clone_url', with: wiki.http_url_to_repo)

    click_link 'HTTP' # open the dropdown
    click_link 'SSH'  # select the dropdown option

    expect(page).to have_css('#clone-dropdown', text: 'SSH')
    expect(page).to have_field('clone_url', with: wiki.ssh_url_to_repo)
  end
end
