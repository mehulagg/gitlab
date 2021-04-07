# frozen_string_literal: true

module Types
  class ExportableTypeEnum < BaseEnum
    value 'Epic', value: ::Types::EpicType, description: 'Epic.'
    value 'Event', value: ::Types::EventType, description: 'Event.'
    value 'Note', value: ::Types::Notes::NoteType, description: 'Note.'
    value 'AwardEmoji', value: ::Types::AwardEmojis::AwardEmojiType, description: 'AwardEmoji.'
  end
end
