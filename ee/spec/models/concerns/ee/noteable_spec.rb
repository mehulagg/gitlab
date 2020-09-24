# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Noteable do
  subject(:klazz) { Class.new { include Noteable } }

  describe '.replyable_types' do
    it 'adds Epic to replyable_types after being included' do
      expect(klazz.replyable_types).to include("Epic")
    end

    it 'adds Vulnerability to replyable_types after being included' do
      expect(klazz.replyable_types).to include("Vulnerability")
    end
  end
end
