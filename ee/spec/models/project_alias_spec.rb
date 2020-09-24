# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectAlias do
  subject { build(:project_alias) }

  it { is_expected.to belong_to(:project) }

  it { is_expected.to validate_presence_of(:project) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.not_to allow_value('/foo').for(:name) }
  it { is_expected.not_to allow_value('foo/foo').for(:name) }
  it { is_expected.not_to allow_value('foo.git').for(:name) }
end
