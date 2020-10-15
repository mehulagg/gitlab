# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Requirements list', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:user_guest) { create(:user) }
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:requirement1) { create(:requirement, project: project, title: 'Some requirement-1', author: user, created_at: 5.days.ago, updated_at: 2.days.ago) }
  let_it_be(:requirement2) { create(:requirement, project: project, title: 'Some requirement-2', author: user, created_at: 6.days.ago, updated_at: 2.days.ago) }
  let_it_be(:requirement3) { create(:requirement, project: project, title: 'Some requirement-3', author: user, created_at: 7.days.ago, updated_at: 2.days.ago) }
  let_it_be(:requirement_archived) { create(:requirement, project: project, title: 'Some requirement-3', state: :archived, author: user, created_at: 8.days.ago, updated_at: 2.days.ago) }

  def create_requirement(title)
    page.within('.nav-controls') do
      find('button.js-new-requirement').click
    end

    page.within('.requirements-list-container') do
      find('textarea#requirementTitle').native.send_keys title
      find('button.js-requirement-save').click

      wait_for_all_requests
    end
  end

  before do
    stub_licensed_features(requirements: true)
    project.add_maintainer(user)
    project.add_guest(user_guest)

    sign_in(user)
  end

  context 'when requirements exist for the project' do
    before do
      visit project_requirements_management_requirements_path(project)

      wait_for_requests
    end

    it 'shows the requirements in the navigation sidebar' do
      expect(first('.nav-sidebar  .active a .nav-item-name')).to have_content('Requirements')
    end

    it 'shows requirements tabs for each status type' do
      page.within('.requirements-state-filters') do
        expect(page).to have_selector('li > a#state-opened')
        expect(find('li > a#state-opened')[:title]).to eq('Filter by requirements that are currently opened.')
        expect(find('li > a#state-opened .badge')).to have_content('3')

        expect(page).to have_selector('li > a#state-archived')
        expect(find('li > a#state-archived')[:title]).to eq('Filter by requirements that are currently archived.')
        expect(find('li > a#state-archived .badge')).to have_content('1')

        expect(page).to have_selector('li > a#state-all')
        expect(find('li > a#state-all')[:title]).to eq('Show all requirements.')
        expect(find('li > a#state-all .badge')).to have_content('4')
      end
    end

    context 'new requirement' do
      it 'shows requirement create form when "New requirement" button is clicked' do
        page.within('.nav-controls') do
          find('button.js-new-requirement').click
        end

        page.within('.requirements-list-container') do
          expect(page).to have_selector('.requirement-form')
        end
      end

      it 'disables new requirement button while create form is open' do
        page.within('.nav-controls') do
          find('button.js-new-requirement').click
          expect(find('button.js-new-requirement')[:disabled]).to eq "true"
        end
      end

      it 'creates new requirement' do
        requirement_title = 'Foobar'

        create_requirement(requirement_title)

        page.within('.requirements-list-container') do
          expect(page).to have_selector('li.requirement', count: 4)
          page.within('.requirements-list li.requirement', match: :first) do
            expect(page.find('.issue-title-text')).to have_content(requirement_title)
          end
        end
      end

      it 'updates requirements count in nav sidebar and opened and all tab badges' do
        page.within('.requirements-state-filters') do
          expect(find('li > a#state-opened .badge')).to have_content('3')
          expect(find('li > a#state-all .badge')).to have_content('4')
        end

        create_requirement('Foobar')

        page.within('.requirements-state-filters') do
          expect(find('li > a#state-opened .badge')).to have_content('4')
          expect(find('li > a#state-all .badge')).to have_content('5')
        end
      end
    end

    context 'open tab' do
      it 'shows button "New requirement"' do
        page.within('.nav-controls') do
          expect(page).to have_selector('button.js-new-requirement')
          expect(find('button.js-new-requirement')).to have_content('New requirement')
        end
      end

      it 'shows list of all open requirements' do
        page.within('.requirements-list-container .requirements-list') do
          expect(page).to have_selector('li.requirement', count: 3)
        end
      end

      it 'shows title, metadata and actions within each requirement item' do
        page.within('.requirements-list li.requirement', match: :first) do
          expect(page.find('.issuable-reference')).to have_content("REQ-#{requirement1.iid}")
          expect(page.find('.issue-title-text')).to have_content(requirement1.title)
          expect(page.find('.issuable-authored')).to have_content('created 5 days ago by')
          expect(page.find('.author')).to have_content(user.name)
          expect(page.find('.controls')).to have_selector('li.requirement-edit button[title="Edit"]')
          expect(page.find('.controls')).to have_selector('li.requirement-archive button[title="Archive"]')
          expect(page.find('.issuable-updated-at')).to have_content('updated 2 days ago')
        end
      end

      it 'shows edit form when edit button is clicked for a requirement' do
        requirement_title = 'Foobar'

        page.within('.requirements-list li.requirement', match: :first) do
          find('li.requirement-edit button[title="Edit"]').click
        end

        page.within('.requirement-form') do
          find('textarea#requirementTitle').native.send_keys requirement_title
          find('button.js-requirement-save').click

          wait_for_all_requests
        end

        page.within('.requirements-list li.requirement', match: :first) do
          expect(page.find('.issue-title-text')).to have_content(requirement_title)
        end
      end

      it 'saves updated title for requirement using edit form' do
        page.within('.requirements-list li.requirement', match: :first) do
          find('li.requirement-edit button[title="Edit"]').click
        end

        page.within('.requirement-form') do
          expect(page.find('span', match: :first)).to have_content("REQ-#{requirement1.iid}")
          expect(page.find('textarea#requirementTitle')['value']).to have_content("#{requirement1.title}")
          expect(page.find('.js-requirement-save')).to have_content('Save changes')
        end
      end

      it 'archives a requirement' do
        page.within('.requirements-list li.requirement', match: :first) do
          find('li.requirement-archive button[title="Archive"]').click

          wait_for_requests
        end

        expect(page.find('.requirements-list-container')).to have_selector('li.requirement', count: 2)
        page.within('.requirements-state-filters') do
          expect(find('li > a#state-opened .badge')).to have_content('2')
          expect(find('li > a#state-archived .badge')).to have_content('2')
        end
      end
    end

    context 'archived tab' do
      before do
        find('li > a#state-archived').click

        wait_for_requests
      end

      it 'does not show button "New requirement"' do
        expect(page).not_to have_selector('.nav-controls button.js-new-requirement')
      end

      it 'shows list of all archived requirements' do
        page.within('.requirements-list-container .requirements-list') do
          expect(page).to have_selector('li.requirement', count: 1)
        end
      end

      it 'shows title, metadata and actions within each requirement item' do
        page.within('.requirements-list li.requirement', match: :first) do
          expect(page.find('.issuable-reference')).to have_content("REQ-#{requirement_archived.iid}")
          expect(page.find('.issue-title-text')).to have_content(requirement_archived.title)
          expect(page.find('.issuable-authored')).to have_content('created 1 week ago by')
          expect(page.find('.author')).to have_content(user.name)
          expect(page.find('.controls')).to have_selector('li.requirement-reopen button', text: 'Reopen')
          expect(page.find('.issuable-updated-at')).to have_content('updated 2 days ago')
        end
      end

      it 'reopens a requirement' do
        page.within('.requirements-list li.requirement', match: :first) do
          find('li.requirement-reopen button').click

          wait_for_requests
        end

        expect(page.find('.requirements-list-container')).to have_selector('li.requirement', count: 0)
        page.within('.requirements-state-filters') do
          expect(find('li > a#state-opened .badge')).to have_content('4')
          expect(find('li > a#state-archived .badge')).to have_content('0')
        end
      end
    end

    context 'all tab' do
      before do
        find('li > a#state-all').click

        wait_for_requests
      end

      it 'does not show button "New requirement"' do
        expect(page).not_to have_selector('.nav-controls button.js-new-requirement')
      end

      it 'shows list of all requirements' do
        page.within('.requirements-list-container .requirements-list') do
          expect(page).to have_selector('li.requirement', count: 4)
        end
      end
    end

    context 'filtered search' do
      it 'shows filtered search input field' do
        page.within('.vue-filtered-search-bar-container') do
          expect(page).to have_selector('input.gl-filtered-search-term-input')
        end
      end

      it 'shows sort dropdown' do
        page.within('.vue-filtered-search-bar-container') do
          expect(page).to have_selector('.gl-new-dropdown button.gl-dropdown-toggle')
          expect(page).to have_selector('.gl-new-dropdown ul.dropdown-menu', visible: false)
        end
      end
    end
  end

  context 'when accessing project as guest user' do
    before do
      sign_in(user_guest)
      visit project_requirements_management_requirements_path(project)

      wait_for_requests
    end

    it 'open tab does not show button "New requirement"' do
      expect(page).not_to have_selector('.nav-controls button.js-new-requirement')
    end
  end
end
