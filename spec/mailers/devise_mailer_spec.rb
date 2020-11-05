# frozen_string_literal: true

require 'spec_helper'
require 'email_spec'

RSpec.describe DeviseMailer do
  include EmailSpec::Matchers
  include_context 'gitlab email notification'

  describe "#confirmation_instructions" do
    subject { described_class.confirmation_instructions(user, 'faketoken', {}) }

    context "when confirming a new account" do
      let(:user) { build(:user, created_at: 1.minute.ago, unconfirmed_email: nil) }

      it "shows the expected text" do
        expect(subject.body.encoded).to have_text "Welcome"
        expect(subject.body.encoded).not_to have_text user.email
      end
    end

    context "when confirming the unconfirmed_email" do
      let(:user) { build(:user, unconfirmed_email: 'jdoe@example.com') }

      it "shows the expected text" do
        expect(subject.body.encoded).not_to have_text "Welcome"
        expect(subject.body.encoded).to have_text user.unconfirmed_email
        expect(subject.body.encoded).not_to have_text user.email
      end
    end

    context "when re-confirming the primary email after a security issue" do
      let(:user) { build(:user, created_at: 10.days.ago, unconfirmed_email: nil) }

      it "shows the expected text" do
        expect(subject.body.encoded).not_to have_text "Welcome"
        expect(subject.body.encoded).to have_text user.email
      end
    end
  end

  describe '#password_change_by_admin' do
    subject { described_class.password_change_by_admin(user) }

    let_it_be(:user) { create(:user) }

    it_behaves_like 'an email sent from GitLab'
    it_behaves_like 'it should not have Gmail Actions links'
    it_behaves_like 'a user cannot unsubscribe through footer link'

    it 'is sent to the user' do
      is_expected.to deliver_to user.email
    end

    it 'has the correct subject' do
      is_expected.to have_subject /^Password changed by administrator$/i
    end

    it 'includes the correct content' do
      is_expected.to have_body_text /An administrator changed the password for your GitLab account/
    end

    it 'includes a link to GitLab' do
      is_expected.to have_body_text /#{Gitlab.config.gitlab.url}/
    end
  end

  describe '#user_access_request' do
    subject { described_class.user_access_request(user) }

    let_it_be(:admin) { create(:user, :admin, email: "admin@example.com") }
    let_it_be(:user) { create(:user) }

    it_behaves_like 'an email sent from GitLab'
    it_behaves_like 'it should not have Gmail Actions links'
    it_behaves_like 'a user cannot unsubscribe through footer link'

    it 'is sent to the admin' do
      is_expected.to deliver_to admin.email
      is_expected.to have_body_text /#{admin.name}/
    end

    it 'has the correct subject' do
      is_expected.to have_subject /^GitLab Account Request$/i
    end

    it 'includes the correct content' do
      is_expected.to have_body_text /#{user.name} has asked for a GitLab account on your instance/
    end

    it 'includes a link to GitLab' do
      is_expected.to have_body_text /#{Gitlab.config.gitlab.url}/
    end
  end
end
