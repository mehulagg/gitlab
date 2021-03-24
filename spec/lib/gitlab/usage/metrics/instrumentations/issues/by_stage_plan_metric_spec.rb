# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::Instrumentations::Issues::ByStagePlanMetric do
  let_it_be(:author) { create(:user) }
  let_it_be(:issues) { create_list(:issue, 2, author: author) }

  it_behaves_like 'a correct instrumented metric value', 1
end
