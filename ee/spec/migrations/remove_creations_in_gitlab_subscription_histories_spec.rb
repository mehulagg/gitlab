# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe RemoveCreationsInGitlabSubscriptionHistories do
  before do
    stub_const('GITLAB_SUBSCRIPTION_CREATED', 0)
    stub_const('GITLAB_SUBSCRIPTION_UPDATED', 1)
    stub_const('GITLAB_SUBSCRIPTION_DESTROYED', 2)
  end

  let(:gitlab_subscriptions) { table(:gitlab_subscriptions) }
  let(:gitlab_subscription_histories) { table(:gitlab_subscription_histories) }

  it 'removes creations in gitlab_subscription_histories on gitlab.com' do
    allow(Gitlab).to receive(:com?).and_return(true)

    gitlab_subscription = gitlab_subscriptions.create!
    gitlab_subscription_histories.create! change_type: GITLAB_SUBSCRIPTION_CREATED,
                                          gitlab_subscription_id: gitlab_subscription.id
    gitlab_subscription_histories.create! change_type: GITLAB_SUBSCRIPTION_UPDATED,
                                          seats: 13,
                                          gitlab_subscription_id: gitlab_subscription.id
    gitlab_subscription_histories.create! change_type: GITLAB_SUBSCRIPTION_DESTROYED,
                                          seats: 13,
                                          gitlab_subscription_id: gitlab_subscription.id

    expect { migrate! }.to change { gitlab_subscription_histories.count }.from(3).to(2)
    expect(gitlab_subscription_histories.where(change_type: [GITLAB_SUBSCRIPTION_UPDATED,
                                                             GITLAB_SUBSCRIPTION_DESTROYED]).count) .to eq(2)
    expect(gitlab_subscription_histories.where(change_type: GITLAB_SUBSCRIPTION_CREATED).count) .to eq(0)
  end

  it 'does not run if not on gitlab.com' do
    allow(Gitlab).to receive(:com?).and_return(false)

    gitlab_subscription = gitlab_subscriptions.create!
    gitlab_subscription_histories.create! change_type: GITLAB_SUBSCRIPTION_CREATED,
                                          gitlab_subscription_id: gitlab_subscription.id

    expect { migrate! }.not_to change { gitlab_subscription_histories.count }
    expect(gitlab_subscription_histories.count) .to eq(1)
  end
end
