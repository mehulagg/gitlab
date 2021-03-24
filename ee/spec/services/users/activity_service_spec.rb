# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::ActivityService, '#execute', :request_store, :redis, :clean_gitlab_redis_shared_state do
  include_context 'clear DB Load Balancing configuration'

  let(:user) { create(:user, last_activity_on: last_activity_on) }

  context 'when last activity is in the past' do
    let(:user) { create(:user, last_activity_on: Date.today - 1.week) }

    context 'database load balancing is configured' do
      before do
        # Do not pollute AR for other tests, but rather simulate effect of configure_proxy.
        allow(ActiveRecord::Base.singleton_class).to receive(:prepend)
        ::Gitlab::Database::LoadBalancing.configure_proxy
        allow(ActiveRecord::Base).to receive(:connection).and_return(::Gitlab::Database::LoadBalancing.proxy)
      end

      let(:service) do
        service = described_class.new(user)

        ::Gitlab::Database::LoadBalancing::Session.clear_session

        service
      end

      it 'does not stick to primary' do
        expect(::Gitlab::Database::LoadBalancing::Session.current).not_to be_performed_write

        service.execute

        expect(user.last_activity_on).to eq(Date.today)
        expect(::Gitlab::Database::LoadBalancing::Session.current).to be_performed_write
        expect(::Gitlab::Database::LoadBalancing::Session.current).not_to be_using_primary
      end
    end

    context 'database load balancing is not configured' do
      let(:service) { described_class.new(user) }

      it 'updates user without error' do
        service.execute

        expect(user.last_activity_on).to eq(Date.today)
      end
    end
  end
end
