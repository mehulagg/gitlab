# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::CycleAnalytics::StageEvents::MergeRequestLastEdited do
  it_behaves_like 'value stream analytics event'
end
