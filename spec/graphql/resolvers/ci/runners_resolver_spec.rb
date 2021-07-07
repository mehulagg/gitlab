# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ci::RunnersResolver do
  include GraphqlHelpers

  include_context 'runners resolver setup'

  it_behaves_like Resolvers::Ci::GroupRunnersResolver
end
