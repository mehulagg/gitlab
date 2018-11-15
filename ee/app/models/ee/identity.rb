module EE
  module Identity
    extend ActiveSupport::Concern

    prepended do
      belongs_to :saml_provider

      validates :secondary_extern_uid,
        allow_blank: true,
        uniqueness: {
          scope: ::Identity::UniquenessScopes.scopes,
          case_sensitive: false
        }

      scope :with_secondary_extern_uid, ->(provider, secondary_extern_uid) do
        iwhere(secondary_extern_uid: normalize_uid(provider, secondary_extern_uid)).with_provider(provider)
      end
    end
  end
end
