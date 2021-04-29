# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '1_settings' do
  subject(:cron_jobs) { Settings.cron_jobs }

  context 'sync_seat_link_worker cron job' do
    it 'schedules the job at the correct time' do
      expect(cron_jobs.dig('sync_seat_link_worker', 'cron')).to eq('14 3 * * * UTC')
    end
  end
end
