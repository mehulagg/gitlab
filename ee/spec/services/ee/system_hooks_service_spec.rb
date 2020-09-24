# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::SystemHooksService do
  context 'when group member' do
    let(:group) { create(:group) }
    let(:group_member) { create(:group_member, group: group) }

    context 'event data' do
      it { expect(event_data(group_member, :create)).to include(:event_name, :created_at, :updated_at, :group_name, :group_path, :group_plan, :group_id, :user_name, :user_username, :user_email, :user_id, :group_access) }
      it { expect(event_data(group_member, :destroy)).to include(:event_name, :created_at, :updated_at, :group_name, :group_path, :group_plan, :group_id, :user_name, :user_username, :user_email, :user_id, :group_access) }
    end

    context 'with a Gold plan' do
      let(:group) { create(:group_with_plan, plan: :gold_plan) }

      it 'returns correct group_plan' do
        expect(event_data(group_member, :create)[:group_plan]).to eq('gold')
      end
    end
  end

  context 'when user' do
    let_it_be(:user) { create(:user) }

    context 'event data' do
      context 'for GitLab.com' do
        before do
          expect(Gitlab).to receive(:com?).and_return(true)
        end

        it { expect(event_data(user, :create)).to include(:event_name, :name, :created_at, :updated_at, :email, :user_id, :username, :email_opted_in, :email_opted_in_ip, :email_opted_in_source, :email_opted_in_at) }
        it { expect(event_data(user, :destroy)).to include(:event_name, :name, :created_at, :updated_at, :email, :user_id, :username, :email_opted_in, :email_opted_in_ip, :email_opted_in_source, :email_opted_in_at) }
      end

      context 'for non-GitLab.com' do
        before do
          expect(Gitlab).to receive(:com?).and_return(false)
        end

        it { expect(event_data(user, :create)).to include(:event_name, :name, :created_at, :updated_at, :email, :user_id, :username) }
        it { expect(event_data(user, :destroy)).to include(:event_name, :name, :created_at, :updated_at, :email, :user_id, :username) }
      end
    end
  end

  def event_data(*args)
    SystemHooksService.new.send :build_event_data, *args
  end
end
