# frozen_string_literal: true

require 'rake_helper'

RSpec.describe 'gitlab:user_management tasks' do
  before do
    Rake.application.rake_require 'tasks/gitlab/user_management'
  end

  describe 'update_users_of_a_group' do
    let(:group) { create(:group) }
    it 'returns output info' do
      expect { run_rake_task('gitlab:user_management:update_users_of_a_group', group.id) }.to output(/.*Done.*/).to_stdout
    end
  end
end
