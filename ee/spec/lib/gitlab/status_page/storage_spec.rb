# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::StatusPage::Storage do
  describe '.details_path' do
    subject { described_class.details_path(123) }

    it { is_expected.to eq('data/incident/123.json') }
  end

  describe '.details_url' do
    let_it_be(:issue, reload: true) { create(:issue) }

    subject { described_class.details_url(issue) }

    context 'when issue is not published' do
      it { is_expected.to be_nil }
    end

    context 'with a published incident' do
      let_it_be(:incident) { create(:status_page_published_incident, issue: issue) }

      context 'without a status page setting' do
        it { is_expected.to be_nil }
      end

      context 'when status page setting is disabled' do
        let_it_be(:setting) { create(:status_page_setting, project: issue.project) }

        it { is_expected.to be_nil }
      end

      context 'when status page setting is enabled' do
        let_it_be(:setting) { create(:status_page_setting, :enabled, project: issue.project) }

        before do
          stub_licensed_features(status_page: true)
        end

        it { is_expected.to eq("https://status.gitlab.com/#/data%2Fincident%2F#{issue.iid}.json") }

        context 'when status page setting does not include a url' do
          before do
            setting.update!(status_page_url: nil)
          end

          it { is_expected.to be_nil }
        end
      end
    end
  end

  describe '.list_path' do
    subject { described_class.list_path }

    it { is_expected.to eq('data/list.json') }
  end

  describe '.upload_path' do
    subject { described_class.upload_path(2, '50b7a196557cf72a98e86a7ab4b1ac3b', 'screenshot.png') }

    it { is_expected.to eq('data/incident/2/50b7a196557cf72a98e86a7ab4b1ac3b/screenshot.png') }
  end

  describe '.uploads_path' do
    subject { described_class.uploads_path(2) }

    it { is_expected.to eq('data/incident/2/') }
  end

  it 'MAX_KEYS_PER_PAGE times MAX_PAGES establishes upload limit' do
    # spec intended to fail if page related MAX constants change
    # In order to ensure change to documented MAX_UPLOADS is considered
    expect(Gitlab::StatusPage::Storage::MAX_KEYS_PER_PAGE * Gitlab::StatusPage::Storage::MAX_PAGES).to eq(5000)
  end
end
