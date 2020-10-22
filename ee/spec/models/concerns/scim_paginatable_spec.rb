# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScimPaginatable do
  let(:paginatable_class) { Identity }

  describe 'scim_paginate' do
    let(:start_index) { 1 }
    let(:count) { 1 }

    it 'paginates with offset and limit' do
      expect(paginatable_class).to receive_message_chain(:offset, :limit)

      paginatable_class.scim_paginate(start_index: start_index, count: count)
    end

    it 'translates a 1-based index to an offset of 0' do
      expect(paginatable_class).to receive(:scim_paginate_with_offset_and_limit).with(offset: 0, limit: count)

      paginatable_class.scim_paginate(start_index: 1, count: count)
    end

    it 'handles string input' do
      expect(paginatable_class).to receive(:scim_paginate_with_offset_and_limit).with(offset: start_index - 1, limit: count)

      paginatable_class.scim_paginate(start_index: start_index.to_s, count: count.to_s)
    end

    it 'defaults to offset of 0' do
      expect(paginatable_class).to receive(:scim_paginate_with_offset_and_limit).with(offset: 0, limit: count)

      paginatable_class.scim_paginate(start_index: '', count: count)
    end
  end
end
