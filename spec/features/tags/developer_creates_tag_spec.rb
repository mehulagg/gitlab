# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Developer creates tag' do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, namespace: group) }

  before do
    project.add_developer(user)
    sign_in(user)
  end

  context 'from tag list' do
    before do
      visit project_tags_path(project)
    end

    it 'with an invalid name displays an error' do
      create_tag_in_form(tag: 'v 1.0', ref: 'master')

      expect(page).to have_content 'Tag name invalid'
    end

    it 'with an invalid reference displays an error' do
      create_tag_in_form(tag: 'v2.0', ref: 'foo')

      expect(page).to have_content 'Target foo is invalid'
    end

    it 'that already exists displays an error' do
      create_tag_in_form(tag: 'v1.1.0', ref: 'master')

      expect(page).to have_content 'Tag v1.1.0 already exists'
    end

    it 'with multiline message displays the message in a <pre> block' do
      create_tag_in_form(tag: 'v3.0', ref: 'master', message: "Awesome tag message\n\n- hello\n- world")

      expect(current_path).to eq(
        project_tag_path(project, 'v3.0'))
      expect(page).to have_content 'v3.0'
      page.within 'pre.wrap' do
        expect(page).to have_content "Awesome tag message - hello - world"
      end
    end

    it 'opens dropdown for ref', :js do
      click_link 'New tag'
      ref_row = find('.form-group:nth-of-type(2) .col-sm-10')
      page.within ref_row do
        ref_input = find('[name="ref"]', visible: false)
        expect(ref_input.value).to eq 'master'
        expect(find('.dropdown-toggle-text')).to have_content 'master'

        find('.js-branch-select').click

        expect(find('.dropdown-menu')).to have_content 'empty-branch'
      end
    end
  end

  def create_tag_in_form(tag:, ref:, message: nil, desc: nil)
    click_link 'New tag'
    fill_in 'tag_name', with: tag
    find('#ref', visible: false).set(ref)
    fill_in 'message', with: message unless message.nil?
    click_button 'Create tag'
  end
end
