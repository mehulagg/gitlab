# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'IDE user sees editor info', :js do
  include WebIdeSpecHelpers

  let(:project) { create(:project, :public, :repository) }
  let(:user) { project.owner }

  before do
    sign_in(user)

    ide_visit(project)
  end

  it 'shows line position' do
    ide_open_file('README.md')

    within find('.ide-status-bar') do
      expect(page).to have_content('1:1')
    end

    ide_set_editor_position(4, 10)

    within find('.ide-status-bar') do
      expect(page).not_to have_content('1:1')
      expect(page).to have_content('4:10')
    end
  end

  it 'updates after rename' do
    ide_open_file('README.md')
    ide_set_editor_position(4, 10)

    within find('.ide-status-bar') do
      expect(page).to have_content('markdown')
      expect(page).to have_content('4:10')
    end

    ide_rename_file('README.md', 'READMEZ.txt')

    within find('.ide-status-bar') do
      expect(page).to have_content('plaintext')
      expect(page).to have_content('1:1')
    end
  end

  it 'persists after closing and reopening' do
    ide_open_file('README.md')
    ide_set_editor_position(4, 10)

    ide_close_file('README.md')
    ide_open_file('README.md')

    within find('.ide-status-bar') do
      expect(page).to have_content('markdown')
      expect(page).to have_content('4:10')
    end
  end
end
