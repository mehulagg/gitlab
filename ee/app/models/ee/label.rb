# frozen_string_literal: true

module EE
  module Label
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    SCOPED_LABEL_SEPARATOR = '::'
    SCOPED_LABEL_PATTERN = /^.*#{SCOPED_LABEL_SEPARATOR}/.freeze

    prepended do
      has_many :epic_board_labels, class_name: 'Boards::EpicBoardLabel', inverse_of: :label
      has_many :epic_lists, class_name: 'Boards::EpicList', inverse_of: :label
    end

    def scoped_label?
      SCOPED_LABEL_PATTERN.match?(name)
    end

    def scoped_label_key
      title[Label::SCOPED_LABEL_PATTERN]&.delete_suffix(SCOPED_LABEL_SEPARATOR)
    end

    def scoped_label_value
      title.sub(SCOPED_LABEL_PATTERN, '')
    end

    override :preload_label_subjects
    def self.preload_label_subjects(labels)
      super
      group_labels = labels.select { |label| label.is_a? GroupLabel }

      preloader = ActiveRecord::Associations::Preloader.new
      preloader.preload(group_labels, { group: [:ip_restrictions, :saml_provider] })
    end
  end
end
