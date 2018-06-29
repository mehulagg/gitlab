require 'rails_helper'

feature 'User uploads avatar to profile' do
  let!(:user) { create(:user) }
  let(:avatar_file_path) { Rails.root.join('spec', 'fixtures', 'dk.png') }

  before do
    sign_in user
    visit profile_path
  end

  scenario 'they see their new avatar on their profile' do
    attach_file('user_avatar', avatar_file_path, visible: false)
    click_button 'Update profile settings'

    visit user_path(user)

    expect(page).to have_selector(%Q(img[data-src$="/uploads/-/system/user/avatar/#{user.id}/dk.png"]))

    # Cheating here to verify something that isn't user-facing, but is important
    expect(user.reload.avatar.file).to exist
  end

  scenario 'their new avatar is immediately visible in the header', :js do
    find('.js-user-avatar-input', visible: false).set(avatar_file_path)

    click_button 'Set new profile picture'
    click_button 'Update profile settings'

    wait_for_all_requests

    data_uri = find('.avatar-image .avatar')['src']
    expect(page.find('.header-user-avatar')['src']).to eq data_uri
  end
end
