# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::WrongfullyConfirmedEmailUnconfirmer, schema: 20200615111857 do
  let(:users) { table(:users) }
  let(:emails) { table(:emails) }
  let(:confirmed_at_2_days_ago) { 2.days.ago }
  let(:confirmed_at_3_days_ago) { 3.days.ago }
  let(:one_year_ago) { 1.year.ago }

  let!(:user_needs_migration_1) { users.create!(name: 'user1', email: 'test1@test.com', state: 'active', projects_limit: 1, confirmed_at: confirmed_at_2_days_ago, confirmation_sent_at: one_year_ago) }
  let!(:user_needs_migration_2) { users.create!(name: 'user2', email: 'test2@test.com', state: 'active', projects_limit: 1, confirmed_at: confirmed_at_3_days_ago, confirmation_sent_at: one_year_ago) }
  let!(:user_does_not_need_migration) { users.create!(name: 'user3', email: 'test3@test.com', state: 'active', projects_limit: 1) }
  let!(:inactive_user) { users.create!(name: 'user4', email: 'test4@test.com', state: 'blocked', projects_limit: 1, confirmed_at: confirmed_at_3_days_ago, confirmation_sent_at: one_year_ago) }
  let!(:alert_bot_user) { users.create!(name: 'user5', email: 'test5@test.com', state: 'active', user_type: 2, projects_limit: 1, confirmed_at: confirmed_at_3_days_ago, confirmation_sent_at: one_year_ago) }

  let!(:bad_email_1) { emails.create!(user_id: user_needs_migration_1.id, email: 'other1@test.com', confirmed_at: confirmed_at_2_days_ago, confirmation_sent_at: one_year_ago) }
  let!(:bad_email_2) { emails.create!(user_id: user_needs_migration_2.id, email: 'other2@test.com', confirmed_at: confirmed_at_3_days_ago, confirmation_sent_at: one_year_ago) }
  let!(:bad_email_3_inactive_user) { emails.create!(user_id: inactive_user.id, email: 'other-inactive@test.com', confirmed_at: confirmed_at_3_days_ago, confirmation_sent_at: one_year_ago) }
  let!(:bad_email_4_bot_user) { emails.create!(user_id: alert_bot_user.id, email: 'other-bot@test.com', confirmed_at: confirmed_at_3_days_ago, confirmation_sent_at: one_year_ago) }

  let!(:good_email_1) { emails.create!(user_id: user_needs_migration_2.id, email: 'other3@test.com', confirmed_at: confirmed_at_2_days_ago, confirmation_sent_at: one_year_ago) }
  let!(:good_email_2) { emails.create!(user_id: user_needs_migration_2.id, email: 'other4@test.com', confirmed_at: nil) }
  let!(:good_email_3) { emails.create!(user_id: user_does_not_need_migration.id, email: 'other5@test.com', confirmed_at: confirmed_at_2_days_ago, confirmation_sent_at: one_year_ago) }

  subject do
    email_ids = [bad_email_1, bad_email_2, good_email_1, good_email_2, good_email_3].map(&:id)

    described_class.new.perform(email_ids.min, email_ids.max)
  end

  it 'does not change irrelevant email records' do
    subject

    expect(good_email_1.reload.confirmed_at).to be_within(1.second).of(confirmed_at_2_days_ago)
    expect(good_email_2.reload.confirmed_at).to be_nil
    expect(good_email_3.reload.confirmed_at).to be_within(1.second).of(confirmed_at_2_days_ago)

    expect(bad_email_3_inactive_user.reload.confirmed_at).to be_within(1.second).of(confirmed_at_3_days_ago)
    expect(bad_email_4_bot_user.reload.confirmed_at).to be_within(1.second).of(confirmed_at_3_days_ago)

    expect(good_email_1.reload.confirmation_sent_at).to be_within(1.second).of(one_year_ago)
    expect(good_email_2.reload.confirmation_sent_at).to be_nil
    expect(good_email_3.reload.confirmation_sent_at).to be_within(1.second).of(one_year_ago)

    expect(bad_email_3_inactive_user.reload.confirmation_sent_at).to be_within(1.second).of(one_year_ago)
    expect(bad_email_4_bot_user.reload.confirmation_sent_at).to be_within(1.second).of(one_year_ago)
  end

  it 'does not change irrelevant user records' do
    subject

    expect(user_does_not_need_migration.reload.confirmed_at).to be_nil
    expect(inactive_user.reload.confirmed_at).to be_within(1.second).of(confirmed_at_3_days_ago)
    expect(alert_bot_user.reload.confirmed_at).to be_within(1.second).of(confirmed_at_3_days_ago)

    expect(user_does_not_need_migration.reload.confirmation_sent_at).to be_nil
    expect(inactive_user.reload.confirmation_sent_at).to be_within(1.second).of(one_year_ago)
    expect(alert_bot_user.reload.confirmation_sent_at).to be_within(1.second).of(one_year_ago)
  end

  it 'updates confirmation_sent_at column' do
    subject

    expect(user_needs_migration_1.reload.confirmation_sent_at).to be_within(1.minute).of(Time.now)
    expect(user_needs_migration_2.reload.confirmation_sent_at).to be_within(1.minute).of(Time.now)

    expect(bad_email_1.reload.confirmation_sent_at).to be_within(1.minute).of(Time.now)
    expect(bad_email_2.reload.confirmation_sent_at).to be_within(1.minute).of(Time.now)
  end

  it 'unconfirms bad email records' do
    subject

    expect(bad_email_1.reload.confirmed_at).to be_nil
    expect(bad_email_2.reload.confirmed_at).to be_nil

    expect(bad_email_1.reload.confirmation_token).not_to be_nil
    expect(bad_email_2.reload.confirmation_token).not_to be_nil
  end

  it 'unconfirms user records' do
    subject

    expect(user_needs_migration_1.reload.confirmed_at).to be_nil
    expect(user_needs_migration_2.reload.confirmed_at).to be_nil

    expect(user_needs_migration_1.reload.confirmation_token).not_to be_nil
    expect(user_needs_migration_2.reload.confirmation_token).not_to be_nil
  end

  context 'enqueued jobs' do
    let(:user_1_gid) { User.find(user_needs_migration_1.id).to_gid.to_s }
    let(:user_2_gid) { User.find(user_needs_migration_2.id).to_gid.to_s }

    let(:email_1_gid) { Email.find(bad_email_1.id).to_gid.to_s }
    let(:email_2_gid) { Email.find(bad_email_2.id).to_gid.to_s }

    it 'enqueues the email confirmation and the unconfirm notification mailer jobs' do
      subject

      expect(enqueued_jobs.size).to eq(6)

      expected_job_arguments = [
        [
          'DeviseMailer',
          'confirmation_instructions',
          'deliver_now',
          { "_aj_globalid" => email_1_gid },
          bad_email_1.reload.confirmation_token
        ],
        [
          'DeviseMailer',
          'confirmation_instructions',
          'deliver_now',
          { "_aj_globalid" => email_2_gid },
          bad_email_2.reload.confirmation_token
        ],
        [
          'DeviseMailer',
          'confirmation_instructions',
          'deliver_now',
          { "_aj_globalid" => user_1_gid },
          user_needs_migration_1.reload.confirmation_token
        ],
        [
          'Gitlab::BackgroundMigration::Mailers::UnconfirmMailer',
          'unconfirm_notification_email',
          'deliver_now',
          { "_aj_globalid" => user_1_gid }
        ],
        [
          'DeviseMailer',
          'confirmation_instructions',
          'deliver_now',
          { "_aj_globalid" => user_2_gid },
          user_needs_migration_2.reload.confirmation_token
        ],
        [
          'Gitlab::BackgroundMigration::Mailers::UnconfirmMailer',
          'unconfirm_notification_email',
          'deliver_now',
          { "_aj_globalid" => user_2_gid }
        ]
      ]

      all_job_arguments = enqueued_jobs.map { |job| job["arguments"] }

      expected_job_arguments.each do |job_arguments|
        expect(all_job_arguments).to include(job_arguments)
      end
    end
  end
end
