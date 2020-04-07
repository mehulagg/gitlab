# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require_relative '../../../../rubocop/cop/gitlab/json'

describe RuboCop::Cop::Gitlab::Json do # rubocop:disable RSpec/FilePath
  include CopHelper

  subject(:cop) { described_class.new }

  shared_examples('registering include offense') do |options|
    let(:offending_lines) { options[:offending_lines] }

    it 'registers an offense when the class includes JSON' do
      inspect_source(source)

      aggregate_failures do
        expect(cop.offenses.size).to eq(offending_lines.size)
        expect(cop.offenses.map(&:line)).to eq(offending_lines)
      end
    end
  end

  shared_examples('registering call offense') do |options|
    let(:offending_lines) { options[:offending_lines] }

    it 'registers an offense when the class calls JSON' do
      inspect_source(source)

      aggregate_failures do
        expect(cop.offenses.size).to eq(offending_lines.size)
        expect(cop.offenses.map(&:line)).to eq(offending_lines)
      end
    end
  end

  context 'when source is a regular module' do
    it_behaves_like 'registering include offense', offending_lines: [2] do
      let(:source) do
        <<~RUBY
          module M
            include JSON
          end
        RUBY
      end
    end
  end

  context 'when source is a regular class' do
    it_behaves_like 'registering include offense', offending_lines: [2] do
      let(:source) do
        <<~RUBY
          class Foo
            include JSON
          end
        RUBY
      end
    end
  end

  context 'when JSON is called' do
    it_behaves_like 'registering call offense', offending_lines: [3] do
      let(:source) do
        <<~RUBY
          class Foo
            def bar
              JSON.parse('{ "foo": "bar" }')
            end
          end
        RUBY
      end
    end
  end
end
