# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::Instrumentations::Issues::CountAllMetric do
  let_it_be(:issue) { create(:issue) }

  it_behaves_like 'a correct instrumented metric value', 1
end
