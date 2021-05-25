# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User views iteration cadences', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:cadence) { create(:iterations_cadence, group: group) }
  let_it_be(:other_cadence) { create(:iterations_cadence, group: group) }
  let_it_be(:cadence_without_iterations) { create(:iterations_cadence, group: group) }
  let_it_be(:iteration_in_cadence) { create(:iteration, group: group, iterations_cadence: cadence) }
  let_it_be(:iteration_in_other_cadence) { create(:iteration, group: group, iterations_cadence: other_cadence) }

  before do
    stub_licensed_features(iterations: true)
  end

  it 'shows iteration cadences with iterations when expanded', :aggregate_failures do
    visit group_iteration_cadences_path(group)

    expect(page).to have_title('Iteration cadences')
    expect(page).to have_content(cadence.title)
    expect(page).to have_content(other_cadence.title)
    expect(page).not_to have_content(iteration_in_cadence.title)
    expect(page).not_to have_content(iteration_in_other_cadence.title)

    click_button cadence.title

    expect(page).to have_content(iteration_in_cadence.title)
    expect(page).not_to have_content(iteration_in_other_cadence.title)
  end
end
