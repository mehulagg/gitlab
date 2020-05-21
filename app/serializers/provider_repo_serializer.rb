# frozen_string_literal: true

class ProviderRepoSerializer < BaseSerializer
  # This overrided method takes care of which entity should be used
  # to serialize the `issue` based on `serializer` key in `opts` param.
  # Hence, `entity` doesn't need to be declared on the class scope.
  def represent(repo, opts = {})
    entity =
      case opts[:provider]
      when :fogbugz
        ImportFogbugzProviderRepoEntity
      else
        ProviderRepoEntity
      end

    super(repo, opts, entity)
  end
end
