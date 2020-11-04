# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Projects > Show > Schema Markup' do
  let_it_be(:project) do
    create(:project, :repository, :public, :with_avatar, description: 'foobar', tag_list: 'tag1, tag2').tap do |p|
      ::Projects::DetectRepositoryLanguagesService.new(p).execute
    end
  end

  it 'shows SoftwareSourceCode structured markup' do
    visit project_path(project)
    wait_for_requests

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
