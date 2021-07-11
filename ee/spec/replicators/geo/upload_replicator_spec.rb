# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::UploadReplicator do
  let(:model_record) { build(:upload) }

  include_examples 'a blob replicator'
  include_examples 'a verifiable replicator'
end

