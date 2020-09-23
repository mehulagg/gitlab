# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'trials/_skip_trial.html.haml' do
  include ApplicationHelper

  context 'without glm_source' do
    it 'displays skip trial' do
      render 'trials/skip_trial'

      expect(rendered).to have_content("Skip Trial (Continue with Free Account)")
    end
  end

  context 'with glm_source' do
    it 'displays skip trial when using about.gitlab.com' do
      params[:glm_source] = 'about.gitlab.com'

      render 'trials/skip_trial'

      expect(rendered).to have_content("Skip Trial (Continue with Free Account)")
    end

    it 'displays go back to GitLab when using GitLab.com' do
      params[:glm_source] = 'gitlab.com'

      render 'trials/skip_trial'

      expect(rendered).to have_content("Go back to GitLab")
    end
  end
end
