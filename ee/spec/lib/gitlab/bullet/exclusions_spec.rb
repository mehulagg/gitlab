# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::Bullet::Exclusions do
  describe '#validate_paths!' do
    it 'validates paths for existence' do
      described_class.new.validate_paths!
    end
  end
end
