# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Projects > Show > Schema Markup' do
  let_it_be(:project) { create(:project, :repository, :public, :with_avatar, description: 'foobar', tag_list: 'tag1, tag2') }

  it 'shows SoftwareSourceCode structured markup', :js do
    visit project_path(project)
    wait_for_all_requests

    aggregate_failures do
      expect(page).to have_selector('[itemscope][itemtype="http://schema.org/SoftwareSourceCode"]')
      expect(page).to have_selector('img[itemprop="image"]')
      expect(page).to have_selector('[itemprop="name"]')
      expect(page).to have_selector('[itemprop="identifier"]')
      expect(page).to have_selector('[itemprop="abstract"]')
      expect(page).to have_selector('[itemprop="license"]')
      expect(page).to have_selector('[itemprop="keywords"]')
      expect(page).to have_selector('[itemprop="about"]')
    end
  end
end
