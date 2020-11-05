# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Git::Conflict::LineParser do
  describe '.assign_type' do
    let(:parser) { described_class.new(path, conflicts) }
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

    before do
      diff_lines.each { |line| parser.assign_type!(line) }
    end

    context 'when the file has valid conflicts' do
      let(:conflicts) { [double(our_path: path, their_path: path)] }

      let(:diff_lines) do
        text.lines.map { |line| Gitlab::Diff::Line.new(line.chomp, nil, 0, 0, 0) }
      end

      it 'assigns conflict types to the diff lines' do
        expect(diff_lines.map(&:type)).to eq([
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

      let(:diff_lines) do
        text.lines.map { |line| double(text: line, type: 'new') }
      end

      it 'does not change type of the diff lines' do
        expect(diff_lines.map(&:type).uniq).to eq(['new'])
      end
    end
  end
end
