# frozen_string_literal: true

module Vulnerabilities
  class UserNotesCountService < ::BaseCountService
    VERSION = 1

    def initialize(vulnerability)
      self.vulnerability = vulnerability
    end

    def relation_for_count
      vulnerability.notes.user
    end

    # Overrides super class' #raw method as we are just
    # storing primitive value in cache.
    def raw?
      true
    end

    def cache_key
      ['vulnerabilities', 'user_notes_count', VERSION, vulnerability.id]
    end

    private

    attr_accessor :vulnerability
  end
end
