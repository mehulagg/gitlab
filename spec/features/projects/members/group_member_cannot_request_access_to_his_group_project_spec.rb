require 'spec_helper'

describe 'Projects > Members > Group member cannot request access to his group project' do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:project) { create(:project, namespace: group) }

  it 'owner does not see the request access button' do
    group.add_owner(user)
    login_and_visit_project_page(user)

    expect(page).not_to have_content 'Request Access'
  end

  it 'master does not see the request access button' do
    group.add_master(user)
    login_and_visit_project_page(user)

    expect(page).not_to have_content 'Request Access'
  end

  it 'developer does not see the request access button' do
    group.add_developer(user)
    login_and_visit_project_page(user)

    expect(page).not_to have_content 'Request Access'
  end

  it 'reporter does not see the request access button' do
    group.add_reporter(user)
    login_and_visit_project_page(user)

    expect(page).not_to have_content 'Request Access'
  end

  it 'guest does not see the request access button' do
    group.add_guest(user)
    login_and_visit_project_page(user)

    expect(page).not_to have_content 'Request Access'
  end

  def login_and_visit_project_page(user)
    sign_in(user)
    visit project_path(project)
  end
end
