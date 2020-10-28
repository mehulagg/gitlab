# frozen_string_literal: true

module HaveFileMatcher
  RSpec::Matchers.define :have_file do |file|
    match do |actual|
      expect(actual.has_file?(file)).to be true
    end

    match_when_negated do |actual|
      expect(actual.has_no_file?(file)).to be true
    end
  end
end
