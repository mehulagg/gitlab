# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Iteration do
  let_it_be(:project) { create(:project) }
  let_it_be(:group) { create(:group) }

  it_behaves_like 'a timebox', :iteration do
    let(:timebox_args) { [:skip_project_validation] }
    let(:timebox_table_name) { described_class.table_name.to_sym }

    # Overrides used during .within_timeframe
    let(:mid_point) { 1.year.from_now.to_date }
    let(:open_on_left) { min_date - 100.days }
    let(:open_on_right) { max_date + 100.days }
  end
end
