# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::Processable do
  describe 'delegations' do
    subject { Ci::Processable.new }

    it { is_expected.to delegate_method(:merge_train_pipeline?).to(:pipeline) }
  end
end
