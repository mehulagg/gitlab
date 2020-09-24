# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::UsageDataCounters::LicensesList do
  it_behaves_like 'a redis usage counter', 'LicensesList', :views

  it_behaves_like 'a redis usage counter with totals', :licenses_list, views: 7
end
