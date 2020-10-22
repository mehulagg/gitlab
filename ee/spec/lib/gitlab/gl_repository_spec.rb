# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::GlRepository do
  describe '.parse' do
    let_it_be(:group) { create(:group) }

    # Group Wiki is a GitLab Starter feature
    it 'parses a group wiki gl_repository' do
      expect(described_class.parse("group-#{group.id}-wiki")).to eq([group.wiki, nil, Gitlab::GlRepository::WIKI])
    end
  end
end
