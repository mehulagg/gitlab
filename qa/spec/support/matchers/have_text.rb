# frozen_string_literal: true

module Matchers
  class HaveText
    def initialize(text, **kwargs)
      @text = text
      @kwargs = kwargs
    end

    def matches?(page_object)
      @page_object = page_object
      @page_object.has_text?(@text, **@kwargs)
    end

    def does_not_match?(page_object)
      @page_object = page_object
      @page_object.has_no_text?(@text, **@kwargs)
    end

    def failure_message
      "expected to find text \"#{@text}\" in \"#{normalized_text}\""
    end

    def failure_message_when_negated
      "expected not to find text \"#{@text}\" in \"#{normalized_text}\""
    end

    def normalized_text
      @page_object.text.gsub(/\s+/, " ")
    end
  end

  def have_text(text, **kwargs) # rubocop:disable Naming/PredicateName
    HaveText.new(text, **kwargs)
  end

  alias_method :have_content, :have_text
end
