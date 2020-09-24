# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::UserNotesCountService, :use_clean_rails_memory_store_caching do
  let_it_be(:vulnerability) { create(:vulnerability) }

  subject { described_class.new(vulnerability) }

  it_behaves_like 'a counter caching service'
end
