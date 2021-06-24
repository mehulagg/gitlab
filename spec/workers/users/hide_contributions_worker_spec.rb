# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::HideContributionsWorker do
  let_it_be(:current_user) { create(:admin) }
  let_it_be(:user) { create(:user) }
  let_it_be(:other_issue) { create(:issue) }

  subject(:worker) { described_class.new }

  describe 'hide issues' do
    include_examples 'an idempotent worker' do
      subject do
        perform_multiple([user.id], worker: worker)
      end
    end

    it "hides issues authored by the user" do
      issue = create(:issue, author: user)

      expect { worker.perform(user.id) }.to change { issue.reload.hidden? }.from(false).to(true)
    end

    it "does not affect issues not created by the banned user" do
      expect { worker.perform(user.id) }.not_to change { other_issue.reload.hidden? }
    end
  end
end
