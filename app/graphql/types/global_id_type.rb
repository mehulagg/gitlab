# frozen_string_literal: true

module GraphQLExtensions
  module ScalarExtensions
    # Allow ID to unify with GlobalID Types
    def ==(other)
      if name == 'ID' && other.is_a?(self.class) &&
          other.type_class.ancestors.include?(::Types::GlobalIDType)
        return true
      end

      super
    end
  end
end

::GraphQL::ScalarType.prepend(GraphQLExtensions::ScalarExtensions)

module Types
  class GlobalIDType < BaseScalar
    # better name, like adapter or something
    # or perhaps a yaml file?
    DEPRECATED = [
      {
        old_model_name: 'PrometheusService',
        new_model_name: 'Integrations::Prometheus',
        deprecated_in: '14.0'
      }
    ].freeze

    ADAPTED_MODEL_NAMES = DEPRECATED.to_h { |d| d.values_at(:old_model_name, :new_model_name) }.freeze

    graphql_name 'GlobalID'
    description <<~DESC
      A global identifier.

      A global identifier represents an object uniquely across the application.
      An example of such an identifier is `"gid://gitlab/User/1"`.

      Global identifiers are encoded as strings.
    DESC

    # @param value [GID]
    # @return [String]
    def self.coerce_result(value, _ctx)
      ::Gitlab::GlobalId.as_global_id(value).to_s
    end

    # @param value [String]
    # @return [GID]
    def self.coerce_input(value, _ctx)
      return if value.nil?

      gid = GlobalID.parse(value)
      raise GraphQL::CoercionError, "#{value.inspect} is not a valid Global ID" if gid.nil?
      raise GraphQL::CoercionError, "#{value.inspect} is not a Gitlab Global ID" unless gid.app == GlobalID.app

      if adapted_model_name = ADAPTED_MODEL_NAMES[gid.model_name]
        # TODO log a deprecation alert?
        gid.uri.instance_variable_set(:@model_name, adapted_model_name)
      end

      gid
    end

    # Construct a restricted type, that can only be inhabited by an ID of
    # a given model class.
    def self.[](model_class)
      @id_types ||= {}

      @id_types[model_class] ||= define_id_type(model_class)
    end

    def self.define_id_type(model_class)
      id_type = Class.new(self) do
        define_singleton_method(:description_string) do
          <<~MD
            A `#{graphql_name}` is a global ID. It is encoded as a string.

            An example `#{graphql_name}` is: `"#{::Gitlab::GlobalId.build(model_name: model_class.name, id: 1)}"`.
          MD
        end

        graphql_name "#{model_class.name.gsub(/::/, '')}ID"
        description description_string

        define_singleton_method(:to_s) do
          graphql_name
        end

        define_singleton_method(:inspect) do
          graphql_name
        end

        define_singleton_method(:as) do |new_name|
          if @renamed && graphql_name != new_name
            raise "Conflicting names for ID of #{model_class.name}: " \
                  "#{graphql_name} and #{new_name}"
          end

          @renamed = true
          graphql_name(new_name)
          description(description_string)
          self
        end

        define_singleton_method(:coerce_result) do |gid, ctx|
          global_id = ::Gitlab::GlobalId.as_global_id(gid, model_name: model_class.name)

          next global_id.to_s if suitable?(global_id)

          raise GraphQL::CoercionError, "Expected a #{model_class.name} ID, got #{global_id}"
        end

        define_singleton_method(:suitable?) do |gid|
          next false if gid.nil?

          gid.model_name.safe_constantize.present? &&
            gid.model_class.ancestors.include?(model_class)
        end

        define_singleton_method(:coerce_input) do |string, ctx|
          gid = super(string, ctx)
          next gid if suitable?(gid)

          raise GraphQL::CoercionError, "#{string.inspect} does not represent an instance of #{model_class.name}"
        end
      end

      if old_model_name = ADAPTED_MODEL_NAMES.invert[model_class.name]
        id_type.as("#{old_model_name}ID")
      end

      id_type
    end
    private_class_method :define_id_type
  end
end
