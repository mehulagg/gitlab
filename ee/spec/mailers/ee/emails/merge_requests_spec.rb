# frozen_string_literal: true

require 'spec_helper'
require 'email_spec'

RSpec.describe EE::Emails::MergeRequests do
  include EmailSpec::Matchers

  let(:user) { create(:user) }
  let(:merge_request) { create(:merge_request) }
  let(:current_user) { create(:user) }

  describe '#add_merge_request_approver_email' do
    subject { Notify.add_merge_request_approver_email(user.id, merge_request.id, current_user.id) }

    context 'when email_author_in_body is set' do
      it 'includes the name of the person who added the approver' do
        stub_application_setting(email_author_in_body: true)

        expect(subject).to have_body_text(current_user.name)
      end
    end

    context 'when email_author_in_body is not set' do
      it 'does not include the name of the person who added the approver' do
        stub_application_setting(email_author_in_body: false)

        expect(subject).not_to have_body_text(current_user.name)
      end
    end
  end

  describe '#approved_merge_request_email' do
    subject { Notify.approved_merge_request_email(user.id, merge_request.id, current_user.id) }

    it 'includes the name of the approver' do
      expect(subject).to have_body_text(current_user.name)
    end
  end

  describe '#unapproved_merge_request_email' do
    subject { Notify.unapproved_merge_request_email(user.id, merge_request.id, current_user.id) }

    it 'includes the name of the person who removed their approval' do
      expect(subject).to have_body_text(current_user.name)
    end
  end
end
