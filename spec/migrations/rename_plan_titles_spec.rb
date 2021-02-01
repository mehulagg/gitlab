# frozen_string_literal: true

require 'spec_helper'

require Rails.root.join('db', 'post_migrate', '20210201114748_rename_plan_titles.rb')

RSpec.describe RenamePlanTitles do
  let(:plans) { table(:plans) }

  subject(:migration) { described_class.new }

  describe '#up' do
    it 'updates the plan titles correctly' do
      plans.create!(name: 'silver', title: 'Silver')
      plans.create!(name: 'gold', title: 'Gold')

      migration.up

      premium = plans.find_by(name: 'silver')
      ultimate = plans.find_by(name: 'gold')
      expect(premium.title).to eq('Premium (Formerly Silver)')
      expect(ultimate.title).to eq('Ultimate (Formerly Gold)')
    end
  end

  describe '#down' do
    it 'rollbacks the plan changes correctly' do
      plans.create!(name: 'silver', title: 'Premium (Formerly Silver)')
      plans.create!(name: 'gold', title: 'Ultimate (Formerly Gold)')

      migration.down

      premium = plans.find_by(name: 'silver')
      ultimate = plans.find_by(name: 'gold')
      expect(premium.title).to eq('Silver')
      expect(ultimate.title).to eq('Gold')
    end
  end
end
