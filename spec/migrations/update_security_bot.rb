# frozen_string_literal: true

require 'spec_helper'

require Rails.root.join('db', 'migrate', '20201222170801_update_security_bot.rb')

RSpec.describe UpdateSecurityBot do
  context 'when bot is not created' do
    it 'skips migration' do
      migrate!

      bot = User.where(user_type: 8).last

      expect(bot).to be_nil
    end
  end

  context 'when bot is confirmed' do
    before do
      User.security_bot
      allow(User.security_bot).to receive(:update_attributes)
    end

    it 'skips migration' do
      expect(User.security_bot).not_to receive(:update_attributes)
    end
  end

  context 'when bot is not confirmed' do
    before do
      User.security_bot.update!(confirmed_at: nil)
    end

    it 'update confirmed_at' do
      migrate!

      expect(User.security_bot.confirmed_at).to be_truthy
    end
  end
end
