# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeleteExpiredProjectBotsWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    context 'project bots' do
      let(:project) { create(:project) }
      let(:project_bot) { create(:user, :project_bot) }

      context 'expired project bot' do
        before do
          project.add_user(project_bot, :maintainer, expires_at: 1.day.from_now)
          travel_to(3.days.from_now)
        end

        it 'removes expired project bot membership' do
          expect { worker.perform }.to change { Member.count }.by(-1)
          expect(Member.find_by(user_id: project_bot.id)).to be_nil
        end

        it 'deletes expired project bot' do
          worker.perform

          expect(User.exists?(project_bot.id)).to be(false)
        end
      end
    end
  end
end
