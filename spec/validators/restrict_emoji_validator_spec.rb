# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RestrictEmojiValidator do
  using RSpec::Parameterized::TableSyntax

  subject do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      attr_accessor :name
      validates :name, restrict_emoji: true
    end.new
  end

  where(:value, :is_valid) do
    nil | true
    '' | true
    'Tanuki' | true
    'Koala 🐨' | false
  end

  with_them do
    it 'restricts emojis in strings' do
      subject.name = value

      expect(subject.valid?).to eq(is_valid)
    end
  end
end
