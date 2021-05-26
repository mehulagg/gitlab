# frozen_string_literal: true

#
# Creates a dynamic derived secret for `attr_encrypted`. This ensures each class
# uses a different secret, all based on the common Rails DB key base.
#
# The method can optionally fallback to using the DB key base if decryption fails.
# This is useful for an interim period while existing records are migrated to
# the new secret.
#
# By default the hmac key is based on the including class's name.
# For example, if the including class's name is 'MyClass', the hmac_key` will
# use `MyClass` as the data to derive the secret.
# The key can also be overridden by using the class method:
# `attr_encrypted_hmac_key 'my_custom_hmac_key'`.
#
# Usage:
#
# class MyModel
#   include AttrEncryptedSecret
#
#   attr_encrypted_hmac_key 'my_custom_hmac_key' # optional
#
#   attr_encrypted :token,
#                  mode:      :per_attribute_iv,
#                  algorithm: 'aes-256-gcm',
#                  key: attr_encrypted_secret
#
module AttrEncryptedSecret
  extend ActiveSupport::Concern

  class_methods do
    def attr_encrypted_secret
      Gitlab::Utils.ensure_utf8_size(full_secret, bytes: 32.bytes)
    end

    def attr_encrypted_hmac_key(key = name)
      key.to_s
    end

    # Override the default method to allow specifying fallback to the common secret.
    def attr_encrypted(attr, **options)
      fallback = options.delete(:fallback)

      super(attr, **options)

      if fallback
        alias_method :"upstream_#{attr}", attr

        define_method(attr) do
          begin # rubocop:disable Style/RedundantBegin
            public_send("upstream_#{attr}") # rubocop:disable GitlabSecurity/PublicSend
          rescue OpenSSL::Cipher::CipherError
            instance_variable_get("@#{attribute}") ||
              instance_variable_set("@#{attribute}", decrypt_with_db_key_base(attr))
          end
        end
      end
    end

    private

    def full_secret
      OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('SHA256'),
        ::Settings.attr_encrypted_db_key_base,
        self.attr_encrypted_hmac_key
      )
    end
  end

  private

  def decrypt_with_db_key_base(attr)
    self.class.decrypt(
      attr,
      public_send("encrypted_#{attr}"), # rubocop:disable GitlabSecurity/PublicSend
      evaluated_attr_encrypted_options_for(attr).merge(key: Settings.attr_encrypted_db_key_base_32)
    )
  end
end
