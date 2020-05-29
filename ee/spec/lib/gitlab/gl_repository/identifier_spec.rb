# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::GlRepository::Identifier do
  let_it_be(:group) { create(:group) }

  context 'group wiki' do
    it_behaves_like 'parsing gl_repository identifier' do
      let(:record_id) { group.id }
      let(:identifier) { "group-#{record_id}-wiki" }
      let(:expected_container) { group }
      let(:expected_type) { Gitlab::GlRepository::WIKI }
    end
  end
end
