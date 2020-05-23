# frozen_string_literal: true

class SnippetInputAction
  include ActiveModel::Validations

  ACTIONS = %w[create update delete move].freeze

  ACTIONS.each do |action_const|
    define_method "#{action_const}_action?" do
      action == action_const
    end
  end

  attr_reader :action, :previous_path, :file_path, :content

  validates :action, inclusion: { in: ACTIONS, message: "%{value} is not a valid action" }
  validates :previous_path, presence: true, if: :move_action?
  validates :file_path, presence: true
  validates :content, presence: true, if: :create_action?

  def initialize(action: nil, previous_path: nil, file_path: nil, content: nil)
    @action = action
    @previous_path = previous_path
    @file_path = file_path
    @content = content
  end

  def to_commit_action
    {
      action: action&.to_sym,
      previous_path: previous_path,
      file_path: file_path,
      content: content
    }
  end
end
