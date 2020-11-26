# frozen_string_literal: true

# RestrictEmojiValidator
#
# Validates if there is an emoji in the given string.
#
# Example:
#
#   class User < ActiveRecord::Base
#     validates :name, allow_blank: true, restrict_emoji: true
#   end
#
class RestrictEmojiValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    if value =~ EmojiRegex::RGIEmoji
      record.errors.add(attribute, _('cannot contain an emoji'))
    end
  end
end
