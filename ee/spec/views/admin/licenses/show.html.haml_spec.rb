# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin/licenses/show.html.haml' do
  let_it_be(:license) { create(:license) }

  context 'when trial license is present' do
    before do
      trial_license = create(:license, trial: true)
      assign(:license, trial_license)
    end

    it 'shows content as expected' do
      render

      expect(rendered).to have_content('Buy License')
      expect(rendered).not_to have_content('License overview')
    end
  end

  context 'when non trial license is present' do
    before do
      assign(:license, license)
    end

    it 'shows content as expected' do
      render

      expect(rendered).not_to have_content('Buy License')
      expect(rendered).to have_content('Licensed to')
      expect(rendered).to have_content('Users in License')
      expect(rendered).to have_content('Upload New License')
    end
  end

  context 'when license is not present' do
    it 'does not show content' do
      render

      expect(rendered).not_to have_content('Licensed to')
      expect(rendered).not_to have_content('Users in License')
      expect(rendered).to have_content('Upload New License')
    end
  end

  context 'when licenses are present' do
    before do
      assign(:licenses, [license])
    end

    it 'shows content as expected' do
      render

      expect(rendered).to have_content('License History')
    end
  end

  context 'when licenses are empty' do
    before do
      assign(:licenses, [])
    end

    it 'does not show content' do
      render

      expect(rendered).not_to have_content('License History')
    end
  end

  context 'when licenses are not defined' do
    it 'does not show content' do
      render

      expect(rendered).not_to have_content('License History')
    end
  end
end
