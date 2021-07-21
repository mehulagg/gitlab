# frozen_string_literal: true

require 'spec_helper'

require_migration!

RSpec.describe AddTriggersToIntegrationsTypeNew do
  let(:migration) { described_class.new }
  let(:integrations) { table(:integrations) }

  describe '#up' do
    before do
      migrate!
    end

    describe 'INSERT trigger' do
      it 'sets `type_new` to the same value as `type`' do
        integration = integrations.create!(type: 'JiraService')

        expect(integration.reload).to have_attributes(
          type: 'JiraService',
          type_new: 'Integrations::Jira'
        )
      end
    end

    describe 'UPDATE trigger' do
      it 'sets `type_new` to the same value as `type`' do
        integration = integrations.create!(type: 'JiraService')
        integration.update!(type: 'AsanaService')

        expect(integration.reload).to have_attributes(
          type: 'AsanaService',
          type_new: 'Integrations::Asana'
        )
      end
    end
  end

  describe '#down' do
    before do
      migration.up
      migration.down
    end

    it 'drops the INSERT trigger' do
      integration = integrations.create!(type: 'JiraService')

      expect(integration.reload).to have_attributes(
        type: 'JiraService',
        type_new: nil
      )
    end

    it 'drops the UPDATE trigger' do
      integration = integrations.create!(type: 'JiraService', type_new: 'Integrations::Jira')
      integration.update!(type: 'AsanaService')

      expect(integration.reload).to have_attributes(
        type: 'AsanaService',
        type_new: 'Integrations::Jira'
      )
    end
  end
end
