# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::JobToken::ScopeLink do
  it { is_expected.to belong_to(:source_project) }
  it { is_expected.to belong_to(:target_project) }
  it { is_expected.to belong_to(:added_by) }
end
