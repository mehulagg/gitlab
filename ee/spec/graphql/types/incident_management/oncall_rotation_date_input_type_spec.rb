# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Types::IncidentManagement::OncallRotationDateInputType do
  let(:date) { '2021-02-17' }
  let(:time) { '07:25' }

  let(:input) { { date: date, time: time } }

  it 'accepts date and time' do
    expect(described_class.coerce_isolated_input(input)).to eq(DateTime.parse('2021-02-17 07:25'))
  end

  shared_examples 'invalid date format' do |date|
    context "like #{date}" do
      let(:date) { date }

      it 'raises an argument error' do
        expect { described_class.coerce_isolated_input(input) }
          .to raise_error(Gitlab::Graphql::Errors::ArgumentError, 'Date given is invalid')
      end
    end
  end

  shared_examples 'invalid time format' do |time|
    context "like #{time}" do
      let(:time) { time }

      it 'raises an argument error' do
        expect { described_class.coerce_isolated_input(input) }
          .to raise_error(Gitlab::Graphql::Errors::ArgumentError, 'Time given is invalid')
      end
    end
  end

  shared_examples 'invalid parsed datetime' do |date|
    context "like #{date}" do
      let(:date) { date }

      it 'raises an argument error' do
        expect { described_class.coerce_isolated_input(input) }
          .to raise_error(Gitlab::Graphql::Errors::ArgumentError, 'Date & time is invalid')
      end
    end
  end

  it_behaves_like 'invalid date format', 'YYYY-MM-DD'
  it_behaves_like 'invalid date format', '20000-12-03'
  it_behaves_like 'invalid date format', '19231202'
  it_behaves_like 'invalid date format', '1923-2-02'
  it_behaves_like 'invalid date format', '1923-02-2'

  it_behaves_like 'invalid time format', '99:99'
  it_behaves_like 'invalid time format', '23:60'
  it_behaves_like 'invalid time format', '24:59'
  it_behaves_like 'invalid time format', '123:00'
  it_behaves_like 'invalid time format', '00:99'
  it_behaves_like 'invalid time format', '00:000'
  it_behaves_like 'invalid time format', '0725'

  it_behaves_like 'invalid parsed datetime', '1923-39-02'
  it_behaves_like 'invalid parsed datetime', '2021-02-30'
end
