# frozen_string_literal: true

require 'fast_spec_helper'
require 'rubocop'

require_relative '../../../../../rubocop/cop/rspec/factory_bot/inline_association'

RSpec.describe RuboCop::Cop::RSpec::FactoryBot::InlineAssociation, type: :rubocop do
  include CopHelper

  subject(:cop) { described_class.new }

  shared_examples 'offense' do |code_snippet|
    context "for `#{code_snippet}`" do
      let(:type) { code_snippet[/^(\w+)/, 1] }
      let(:offense_marker) { '^' * code_snippet.size }
      let(:offense_msg) { msg(type) }
      let(:offense) { "#{offense_marker} #{offense_msg}" }
      let(:pristine_source) { source.sub(offense, '') }
      let(:source) do
        <<~RUBY
          FactoryBot.define do
            factory :project do
              attribute { #{code_snippet} }
                          #{offense}
            end
          end
        RUBY
      end

      it 'registers an offense' do
        expect_offense(source)
      end

      it 'autocorrects the source' do
        corrected = autocorrect_source(pristine_source)

        expect(corrected).not_to include(code_snippet)
        expect(corrected).to include('association')
      end
    end
  end

  shared_examples 'no offense' do |code_snippet|
    first_line = code_snippet.lines.first.chomp

    context "for `#{first_line}`" do
      it 'does not register any offenses' do
        expect_no_offenses <<~RUBY
          FactoryBot.define do
            factory :project do
              #{code_snippet}
            end
          end
        RUBY
      end
    end
  end

  context 'offenses' do
    it_behaves_like 'offense', 'create(:user)'
    it_behaves_like 'offense', 'create(:user, :admin)'
    it_behaves_like 'offense', 'create(:user, name: "any")'
    it_behaves_like 'offense', 'build(:user)'
    it_behaves_like 'offense', 'build(:user, :admin)'
    it_behaves_like 'offense', 'create(:user, name: "any")'

    it 'recognizes `add_attribute`' do
      expect_offense <<~RUBY
        FactoryBot.define do
          factory :project, class: 'Project' do
            add_attribute(:method) { create(:user) }
                                     ^^^^^^^^^^^^^ #{msg(:create)}
          end
        end
      RUBY
    end
  end

  context 'no offenses' do
    it_behaves_like 'no offense', <<~RUBY
      after(:build) do |object|
        object.user = create(:user)
      end
    RUBY

    it_behaves_like 'no offense', <<~RUBY
      initialize_with do
        create(:user)
      end
    RUBY

    it_behaves_like 'no offense', <<~RUBY
      user_id { create(:user).id }
    RUBY
  end

  def msg(type)
    format(described_class::MSG, type: type)
  end
end
