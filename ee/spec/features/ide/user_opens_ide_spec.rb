# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'EE user opens IDE', :js do
  include WebIdeSpecHelpers

  let_it_be(:unsigned_commits_warning) { 'This project does not accept unsigned commits.' }

  let(:project) { create(:project, :repository) }
  let(:user) { project.owner }

  before do
    stub_licensed_features(push_rules: true)
    stub_licensed_features(reject_unsigned_commits: true)
    sign_in(user)
  end

  context 'default' do
    before do
      ide_visit(project)
    end

    it 'does not show warning' do
      expect(page).not_to have_text(unsigned_commits_warning)
    end
  end

  context 'when has reject_unsigned_commit push rule' do
    before do
      create(:push_rule, project: project, reject_unsigned_commits: true)

      ide_visit(project)
    end

    it 'shows warning' do
      expect(page).to have_text(unsigned_commits_warning)
    end
  end
end
