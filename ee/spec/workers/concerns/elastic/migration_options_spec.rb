# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::MigrationOptions do
  let(:migration_class) do
    Class.new do
      include Elastic::MigrationOptions
    end
  end

  shared_examples_for 'a boolean option' do |option|
    it 'defaults to false' do
      expect(subject).to be_falsey
    end

    it "respects when #{option} is set for the class" do
      migration_class.public_send(option)

      expect(subject).to be_truthy
    end
  end

  describe '#batched?' do
    subject { migration_class.new.batched? }

    it_behaves_like 'a boolean option', :batched!
  end

  describe '#pause_indexing?' do
    subject { migration_class.new.pause_indexing? }

    it_behaves_like 'a boolean option', :pause_indexing!
  end

  describe '#space_requirements?' do
    subject { migration_class.new.space_requirements? }

    it_behaves_like 'a boolean option', :space_requirements!
  end

  describe '#throttle_delay' do
    subject { migration_class.new.throttle_delay }

    it 'has a default' do
      expect(subject).to eq(described_class::DEFAULT_THROTTLE_DELAY)
    end

    it 'respects when throttle_delay is set for the class' do
      migration_class.throttle_delay 30.seconds

      expect(subject).to eq(30.seconds)
    end
  end
end
