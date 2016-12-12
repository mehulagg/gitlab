module QA
  feature 'standard root login', :ce, :ee do
    scenario 'user logs in using credentials' do
      Page::Main::Entry.act { sign_in_using_credentials }

      expect(page).to have_content('Your projects')
    end
  end
end
