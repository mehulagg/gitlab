# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeleteExpiredProjectBotsWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    context 'project bots' do
      let(:project) { create(:project) }
      let(:expired_project_bot) { create(:user, :project_bot) }
      let(:other_project_bot) { create(:user, :project_bot) }

      context 'expired project bot' do
        before do
          project.add_user(expired_project_bot, :maintainer, expires_at: 1.day.from_now)
          project.add_user(other_project_bot, :maintainer, expires_at: 10.days.from_now)
          travel_to(3.days.from_now)
        end

        it 'removes expired project bot membership' do
          expect { worker.perform }.to change { Member.count }.by(-1)
          expect(Member.find_by(user_id: expired_project_bot.id)).to be_nil
        end

        it 'deletes expired project bot' do
          worker.perform

          expect(User.exists?(expired_project_bot.id)).to be(false)
        end

        it 'does not remove expired project bot that expires in the future' do
          expect { worker.perform }.to change { Member.count }.by(0)
          expect(other_project_bot.reload).to be_present
        end

        it 'does not delete project bot expiring in the future' do
          worker.perform

          expect(User.exists?(other_project_bot.id)).to be(true)
        end
      end
    end
  end
end
