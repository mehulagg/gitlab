# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Git::Conflict::LineParser do
  describe '.assign_type' do
    let(:parser) { described_class.new(path, double(files: conflicts)) }
    let(:path) { 'files/ruby/regex.rb' }

    let(:text) do
      <<~CONFLICT
          module Gitlab
          +<<<<<<< #{path}
              def project_name_regexp
          +=======
              def project_name_regex
          +>>>>>>> #{path}
              end
      CONFLICT
    end

    let(:diff_line_types) do
      text.lines.map { |line| parser.diff_line_type(line.chomp) }
    end

    context 'when the file has valid conflicts' do
      let(:conflicts) { [double(our_path: path, their_path: path)] }

      it 'assigns conflict types to the diff lines' do
        expect(diff_line_types).to eq([
          nil,
          'conflict_marker',
          'conflict_our',
          'conflict_marker',
          'conflict_their',
          'conflict_marker',
          nil
        ])
      end
    end

    context 'when the file does not have conflicts' do
      let(:conflicts) { [] }

      it 'does not change type of the diff lines' do
        expect(diff_line_types).to eq(Array.new(7))
      end
    end
  end
end
