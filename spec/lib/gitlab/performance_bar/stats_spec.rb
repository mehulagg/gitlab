# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::PerformanceBar::Stats do
  describe '#process' do
    let(:request) { fixture_file('lib/gitlab/performance_bar/peek_data.json') }
    let(:redis) { double(Gitlab::Redis::SharedState) }
    let(:logger) { double(Gitlab::PerformanceBar::Logger) }
    let(:request_id) { 'foo' }
    let(:stats) { described_class.new(redis) }

    describe '.gather_stats?' do
      subject(:gather_stats) { described_class.gather_stats? }

      specify { expect(gather_stats).to be_truthy }

      context 'in production env' do
        before do
          stub_rails_env('production')
        end

        specify { expect(gather_stats).to be_falsey }

        context 'on gitlab.com' do
          before do
            allow(Gitlab).to receive(:com?).and_return(true)
          end

          specify { expect(gather_stats).to be_truthy }
        end
      end

      context 'when performance_bar_stats is disabled' do
        before do
          stub_feature_flags(performance_bar_stats: false)
        end

        specify { expect(gather_stats).to be_falsey }
      end
    end

    describe '#process' do
      subject(:process) { stats.process(request_id) }

      before do
        allow(stats).to receive(:logger).and_return(logger)
      end

      it 'logs each SQL query including its duration' do
        allow(redis).to receive(:get).and_return(request)

        expect(logger).to receive(:info)
          .with({ duration_ms: 1.096, filename: 'lib/gitlab/pagination/offset_pagination.rb',
                  method_path: 'lib/gitlab/pagination/offset_pagination.rb:add_pagination_headers',
                  count: 1, request_id: 'foo', type: :sql })
        expect(logger).to receive(:info)
          .with({ duration_ms: 1.634, filename: 'lib/api/helpers.rb',
                  method_path: 'lib/api/helpers.rb:find_project',
                  count: 2, request_id: 'foo', type: :sql })

        subject
      end

      it 'logs an error when the request could not be processed' do
        allow(redis).to receive(:get).and_return(nil)

        expect(logger).to receive(:error).with(message: anything)

        subject
      end
    end
  end
end
