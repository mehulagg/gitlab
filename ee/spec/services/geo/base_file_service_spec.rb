# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::BaseFileService do
  subject { described_class.new('file', 8) }

  describe '#execute' do
    it 'requires a subclass overrides it' do
      expect { subject.execute }.to raise_error(NotImplementedError)
    end
  end
end
