# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MattermostService, let_it_be_light_freeze: false do
  it_behaves_like "slack or mattermost notifications", "Mattermost"
end
