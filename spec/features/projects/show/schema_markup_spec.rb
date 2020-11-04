# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Projects > Show > Schema Markup' do
  let_it_be(:project) { create(:project, :repository, :public, description: 'foobar ') }

  it 'shows SoftwareSourceCode structured markup' do
    allow(project).to receive(:tags).and_return(['v1.0.0', 'v2.0.0'])
    visit project_path(project)

    aggregate_failures do
      expect(page).to have_selector('[itemscope][itemtype="http://schema.org/SoftwareSourceCode"]')
      expect(page).to have_selector('img[itemprop="image"]')
      expect(page).to have_selector('[itemprop="name"]')
      expect(page).to have_selector('[itemprop="identifier"]')
      expect(page).to have_selector('[itemprop="abstract"]')
      expect(page).to have_selector('[itemprop="programmingLanguage"]')
      expect(page).to have_selector('[itemprop="license"]')
      expect(page).to have_selector('[itemprop="keywords"]')
      expect(page).to have_selector('[itemprop="about"]')
    end
  end
end
