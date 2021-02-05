# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emails::UserCap do
  include EmailSpec::Matchers

  let_it_be(:user) { create(:user) }

  describe "#user_cap_reached" do
    subject { Notify.user_cap_reached(user.id) }

    let_it_be(:user_cap) { 100 }
    let_it_be(:url_to_user_cap_docs) do
      'https://docs.gitlab.com/ee/user/admin_area/settings/sign_up_restrictions.html#user-cap'
    end

    before do
      allow(::Gitlab::CurrentSettings).to receive(:new_user_signups_cap?).and_return(user_cap)
    end

    it { is_expected.to have_subject('Important information about usage on your GitLab instance') }
    it { is_expected.to be_delivered_to([user.notification_email]) }
    it { is_expected.to have_body_text('your GitLab instance has reached the maximum allowed') }
    it { is_expected.to have_body_text('user cap') }
  end
end
