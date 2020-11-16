# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Middleware::ReadOnly do
  before do
    allow(Gitlab::Database).to receive(:read_only?) { true }
  end

  it_behaves_like 'write access for a read-only GitLab (EE) instance'
end
