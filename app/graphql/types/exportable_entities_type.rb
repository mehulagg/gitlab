module Types
  class ExportableEntitiesType < Types::BaseUnion
    possible_types Types::LabelType,
      ::Types::EpicType,
      ::Types::EventType,
      ::Types::AwardEmojis::AwardEmojiType,
      ::Types::Notes::NoteType

    def self.resolve_type(object, context)
      puts '*' * 80
      p object: object
      p context: context
      puts '*' * 80
      super
    end
  end
end
