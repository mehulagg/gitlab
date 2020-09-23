# frozen_string_literal: true

module EE
  module Label
    extend ActiveSupport::Concern

    SCOPED_LABEL_SEPARATOR = '::'
    SCOPED_LABEL_PATTERN = /^.*#{SCOPED_LABEL_SEPARATOR}/.freeze

    def scoped_label?
      SCOPED_LABEL_PATTERN.match?(name)
    end

    def scoped_label_key
      title[Label::SCOPED_LABEL_PATTERN]&.delete_suffix(SCOPED_LABEL_SEPARATOR)
    end

    def scoped_label_value
      title.sub(SCOPED_LABEL_PATTERN, '')
    end
  end
end
