# frozen_string_literal: true

require 'spec_helper'
require 'email_spec'

RSpec.describe Emails::Issues do
  include EmailSpec::Matchers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, namespace: group) }
  let_it_be(:issue) { create(:issue, project: project) }

  context 'iterations' do
    let_it_be(:iteration) { create(:iteration, group: group) }

    describe '#changed_iteration_issue_email' do
      subject { Notify.changed_iteration_issue_email(user.id, issue.id, iteration, user.id) }

      it 'shows the iteration it was changed to' do
        expect(subject).to have_body_text 'Iteration changed to'
        expect(subject).to have_body_text iteration.name
      end
    end

    describe '#removed_iteration_issue_email' do
      subject { Notify.removed_iteration_issue_email(user.id, issue.id, user.id) }

      it 'says iteration was removed' do
        expect(subject).to have_body_text 'Iteration removed'
      end
    end
  end
end
