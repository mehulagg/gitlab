module QA
  feature 'standard root login', :ce, :ee do
    scenario 'user logs in using credentials' do
      Page::Main::Entry.act { sign_in_using_credentials }

      # TODO, since `Signed in successfully` message was removed
      # this is the only way to tell if user is signed in correctly.
      #
      Page::Main::Menu.act do
        expect(self).to have_personal_menu
      end
    end
  end
end
