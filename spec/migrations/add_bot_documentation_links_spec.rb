# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20210530185710_add_bot_documentation_links.rb')

RSpec.describe AddBotDocumentationLinks, :migration do
  let(:users) { table(:users) }

  ALL_USER_TYPES = [
    [described_class::User::USER_TYPE_SUPPORT_BOT, 'support_bot'],
    [described_class::User::USER_TYPE_ALERT_BOT, 'alert_bot'],
    [described_class::User::USER_TYPE_VISUAL_REVIEW_BOT, 'visual_review_bot'],
    [described_class::User::USER_TYPE_MIGRATION_BOT, 'migration_bot'],
    [described_class::User::USER_TYPE_SECURITY_BOT, 'security_bot'],
    [described_class::User::USER_TYPE_PROJECT_BOT, 'project_bot'],
    [described_class::User::USER_TYPE_GHOST, 'ghost_user']
  ].freeze

  context 'bot users without website_url set' do
    
    ALL_USER_TYPES.each do |(user_type, user_prefix, _)|

      let!("#{user_prefix}_empty".to_sym) do
        create_user!(
          name: "#{user_prefix}_empty",
          email: "#{user_prefix}_empty@example.com",
          user_type: user_type,
          website_url: ''
        )
      end

    end

    it 'updates their `website_url` attribute' do
      expect { migrate! }
        .to change { support_bot_empty.reload.website_url }
        .and change { alert_bot_empty.reload.website_url }
        .and change { visual_review_bot_empty.reload.website_url }
        .and change { migration_bot_empty.reload.website_url }
        .and change { security_bot_empty.reload.website_url }
        .and change { project_bot_empty.reload.website_url }
        .and change { ghost_user_empty.reload.website_url }
    end

    it 'sets `website_url` to appropriate documentation pages' do
      migrate!

      expect(support_bot_empty.reload.website_url).to eq(Gitlab::Routing.url_helpers.help_page_url('user/project/service_desk.md'))
      expect(alert_bot_empty.reload.website_url).to eq(Gitlab::Routing.url_helpers.help_page_url('operations/incident_management/alerts.md'))
      expect(visual_review_bot_empty.reload.website_url).to eq(Gitlab::Routing.url_helpers.help_page_url('ci/review_apps/index.md'))
      expect(migration_bot_empty.reload.website_url).to eq(Gitlab::Routing.url_helpers.help_page_url('development/internal_users.md'))
      expect(security_bot_empty.reload.website_url).to eq(Gitlab::Routing.url_helpers.help_page_url('user/application_security/security_bot/index.md'))
      expect(project_bot_empty.reload.website_url).to eq(Gitlab::Routing.url_helpers.help_page_url('security/token_overview.md'))
      expect(ghost_user_empty.reload.website_url).to eq(Gitlab::Routing.url_helpers.help_page_url('user/profile/account/delete_account.md'))
    end
  end

  context 'bot users with website_url already set' do
    ALL_USER_TYPES.each do |(user_type, user_prefix, website_url)|

      let!("#{user_prefix}_preset".to_sym) do
        create_user!(
          name: "#{user_prefix}_preset",
          email: "#{user_prefix}_preset@example.com",
          user_type: user_type,
          website_url: 'http://localhost/something/previously/set'
        )
      end

    end

    it 'does not update their `website_url` attribute' do
      RSpec::Matchers.define_negated_matcher :not_change, :change
      expect { migrate! }
        .to not_change { support_bot_preset.reload.website_url }
        .and not_change { alert_bot_preset.reload.website_url }
        .and not_change { visual_review_bot_preset.reload.website_url }
        .and not_change { migration_bot_preset.reload.website_url }
        .and not_change { security_bot_preset.reload.website_url }
        .and not_change { project_bot_preset.reload.website_url }
        .and not_change { ghost_user_preset.reload.website_url }
    end
  end

  context 'human users that are with or without website_url defined' do

    let!(:human_with_website_empty) do
      create_user!(
        name: 'human_empty',
        email: 'human_empty@example.com',
        user_type: nil,
        website_url: ''
      )
    end

    let!(:human_with_website_set) do
      create_user!(
        name: 'human_set',
        email: 'human_set@example.com',
        user_type: nil,
        website_url: 'http://localhost/something/previously/set'
      )
    end

    it 'does not update their `website_url` attribute' do
      RSpec::Matchers.define_negated_matcher :not_change, :change
      expect { migrate! }
        .to not_change { human_with_website_empty.reload.website_url }
        .and not_change { human_with_website_set.reload.website_url }
    end
  end

  private

  def create_user!(name:, email:, user_type:, website_url:)
    users.create!(
      name: name,
      email: email,
      username: name,
      user_type: user_type,
      website_url: website_url,
      projects_limit: 0
    )
  end
end
