# frozen_string_literal: true

class GroupIssuableAutocompleteEntity < Grape::Entity
  expose :iid, if: -> (e, _) { e.respond_to?(:iid) }
  expose :id, if: -> (e, _) { !e.respond_to?(:iid) }
  expose :title
  expose :reference do |issuable, options|
    issuable.to_reference(options[:parent_group])
  end
end
