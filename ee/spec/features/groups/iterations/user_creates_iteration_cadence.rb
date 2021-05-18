# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User views iteration' do
  let_it_be(:now) { Time.now }
  let_it_be(:group) { create(:group) }
  let_it_be(:cadence) { create(:iterations_cadence, group: group) }
  let_it_be(:iteration) { create(:iteration, :skip_future_date_validation, iid: 1, id: 2, group: group, title: 'Correct Iteration', description: 'iteration description', start_date: now - 1.day, due_date: now) }
  let_it_be(:issue) { create(:issue, project: project, iteration: iteration, labels: [label1]) }
  
  context 'with license', :js do
    before do
      stub_licensed_features(iterations: true)
    end

    it 'shows iteration cadences page' do
      visit group_iterations_cadences_path(iteration.group)

      expect(page).to have_title('Iteration cadences')
      expect(page).to have_content(cadence.title)
    end 
  end

  context 'without license' do
    before do
      stub_licensed_features(iterations: false)
      sign_in(user)
    end

    it 'shows page not found' do
      visit group_iterations_cadences_path(iteration.group)

      expect(page).to have_title('Not Found')
      expect(page).to have_content('Page Not Found')
    end
  end
end
