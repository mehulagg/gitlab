# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project > User views empty wiki' do
  let_it_be(:auditor) { create(:user, auditor: true) }
  let_it_be(:project) { create(:project, :private) }
  let_it_be(:wiki) { create(:project_wiki, project: project) }

  describe 'when signed in user is an Auditor' do
    before do
      sign_in(auditor)
    end

    it 'shows empty state without "Suggest wiki improvement" button' do
      visit wiki_path(wiki)

      expect(page).to have_content('This project has no wiki pages')
      expect(page).to have_content('You must be a project member in order to add wiki pages. If you have suggestions for how to improve the wiki for this project, consider opening an issue in the issue tracker.')
      expect(page).not_to have_link('Suggest wiki improvement')
    end
  end
end
