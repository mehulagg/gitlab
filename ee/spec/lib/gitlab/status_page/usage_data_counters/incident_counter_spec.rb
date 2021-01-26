# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::StatusPage::UsageDataCounters::IncidentCounter do
  it_behaves_like 'a redis usage counter', 'StatusPage::IncidentCounter', :publishes
  it_behaves_like 'a redis usage counter', 'StatusPage::IncidentCounter', :unpublishes

  it_behaves_like 'a redis usage counter with totals', :status_page_incident, publishes: 7, unpublishes: 2
end
