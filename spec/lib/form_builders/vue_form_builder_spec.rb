# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FormBuilders::VueFormBuilder do
  subject { described_class.new(:user, nil, self, {}) }

  describe '#field_name_and_id' do
    it 'returns `name` and `id` attributes' do
      result = subject.field_name_and_id(:email)

      expect(result["name"]).to match('user[email]')
      expect(result["id"]).to match('user_email')
    end
  end
end
