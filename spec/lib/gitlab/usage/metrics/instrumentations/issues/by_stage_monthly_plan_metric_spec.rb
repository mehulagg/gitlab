# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::Instrumentations::Issues::ByStageMonthlyPlanMetric do
  let_it_be(:author) { create(:user) }
  let_it_be(:issues) { create_list(:issue, 2, author: author) }
  let_it_be(:old_issue) { create(:issue, author: author, created_at: 2.months.ago) }

  it_behaves_like 'a correct instrumented metric value', 1
end
