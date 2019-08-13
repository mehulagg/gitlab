require 'spec_helper'

describe OpenProjectHttp do
  include Gitlab::Routing
  include AssetsHelpers

  it_behaves_like "OpenProjectHttp"
end