# frozen_string_literal: true

require 'fast_spec_helper'
require_relative '../../../../rubocop/cop/gitlab/avoid_referencing_active_record_base'

RSpec.describe RuboCop::Cop::Gitlab::AvoidReferencingActiveRecordBase do
  subject(:cop) { described_class.new }

  it 'flags the use of ActiveRecord::Base.connection' do
    expect_offense(<<~SOURCE)
    ActiveRecord::Base.connection.inspect
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use ActiveRecord::Base.connection, use ApplicationRecord.connection instead
    SOURCE
  end
end

