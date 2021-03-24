# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::Instrumentations::BoardsMetric do
  let_it_be(:board) { create(:board) }

  it_behaves_like 'a correct instrumented metric value', 1
end
