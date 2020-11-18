# frozen_string_literal: true

module Types
  class BaseField < GraphQL::Schema::Field
    prepend Gitlab::Graphql::Authorize
    include GitlabStyleDeprecations

    argument_class ::Types::BaseArgument

    DEFAULT_COMPLEXITY = 1

    def initialize(**kwargs, &block)
      @calls_gitaly = !!kwargs.delete(:calls_gitaly)
      @constant_complexity = !!kwargs[:complexity]
      @authorize = Array.wrap(kwargs.delete(:authorize))
      kwargs[:complexity] = field_complexity(kwargs[:resolver_class], kwargs[:complexity])
      @feature_flag = kwargs[:feature_flag]
      kwargs = check_feature_flag(kwargs)
      kwargs = gitlab_deprecation(kwargs)

      super(**kwargs, &block)

      extension Gitlab::Graphql::ConnectionFilterExtension # if connection?
    end

    # Based on https://github.com/rmosolgo/graphql-ruby/blob/v1.11.4/lib/graphql/schema/field.rb#L538-L563
    # Modified to fix https://github.com/rmosolgo/graphql-ruby/issues/3113
    def resolve_field(obj, args, ctx)
      ctx.schema.after_lazy(obj) do |after_obj|
        query_ctx = ctx.query.context
        inner_obj = after_obj&.object

        ctx.schema.after_lazy(to_ruby_args(after_obj, args, ctx)) do |ruby_args|
          if authorized?(inner_obj, ruby_args, query_ctx)
            if @resolve_proc
              # We pass `after_obj` here instead of `inner_obj` because extensions expect a GraphQL::Schema::Object
              with_extensions(after_obj, ruby_args, query_ctx) do |extended_obj, extended_args|
                # Since `extended_obj` is now a GraphQL::Schema::Object, we need to get the inner object and pass that to `@resolve_proc`
                extended_obj = extended_obj.object if extended_obj.is_a?(GraphQL::Schema::Object)

                @resolve_proc.call(extended_obj, args, ctx)
              end
            else
              public_send_field(after_obj, ruby_args, query_ctx)
            end
          else
            err = GraphQL::UnauthorizedFieldError.new(object: inner_obj, type: obj.class, context: ctx, field: self)
            query_ctx.schema.unauthorized_field(err)
          end
        end
      end
    end

    # By default fields authorize against the current object, but that is not how our
    # resolvers work - they use declarative permissions to authorize fields
    # manually (so we make them opt in).
    # TODO: separate out authorize into permissions on the object, and on the
    #       resolved values
    def authorized?(object, args, ctx)
      return super unless Feature.enabled?(:graphql_framework_authorization)

      if @authorize.present?
        user = ctx[:current_user]
        return @authorize.all? { |p| Ability.allowed?(user, p, object) }
      end

      if resolver_does_not_consider_object?
        true # ok to proceed
      else
        super
      end
    end

    # Historically our resolvers have used declarative permission checks only
    # for _what they resolved_, not the _object they resolved these things from_
    # We preserve these semantics here:
    def resolver_does_not_consider_object?
      rc = @resolver_class
      return false if rc.nil? # no resolver => no way to know!

      # Resolvers must opt-in to have their objects checked
      return false if rc.respond_to?(:authorizes_object?) && rc.authorizes_object?

      true # by default, permissions on resolvers apply to field values, not objects
    end

    def base_complexity
      complexity = DEFAULT_COMPLEXITY
      complexity += 1 if calls_gitaly?
      complexity
    end

    def calls_gitaly?
      @calls_gitaly
    end

    def constant_complexity?
      @constant_complexity
    end

    def visible?(context)
      return false if feature_flag.present? && !Feature.enabled?(feature_flag)

      super
    end

    private

    attr_reader :feature_flag

    def feature_documentation_message(key, description)
      "#{description}. Available only when feature flag `#{key}` is enabled"
    end

    def check_feature_flag(args)
      args[:description] = feature_documentation_message(args[:feature_flag], args[:description]) if args[:feature_flag].present?
      args.delete(:feature_flag)

      args
    end

    def field_complexity(resolver_class, current)
      return current if current.present? && current > 0

      if resolver_class
        field_resolver_complexity
      else
        base_complexity
      end
    end

    def field_resolver_complexity
      # Complexity can be either integer or proc. If proc is used then it's
      # called when computing a query complexity and context and query
      # arguments are available for computing complexity.  For resolvers we use
      # proc because we set complexity depending on arguments and number of
      # items which can be loaded.
      proc do |ctx, args, child_complexity|
        # Resolvers may add extra complexity depending on used arguments
        complexity = child_complexity + self.resolver&.try(:resolver_complexity, args, child_complexity: child_complexity).to_i
        complexity += 1 if calls_gitaly?
        complexity += complexity * connection_complexity_multiplier(ctx, args)

        complexity.to_i
      end
    end

    def connection_complexity_multiplier(ctx, args)
      # Resolvers may add extra complexity depending on number of items being loaded.
      field_defn = to_graphql
      return 0 unless field_defn.connection?

      page_size   = field_defn.connection_max_page_size || ctx.schema.default_max_page_size
      limit_value = [args[:first], args[:last], page_size].compact.min
      multiplier  = self.resolver&.try(:complexity_multiplier, args).to_f
      limit_value * multiplier
    end
  end
end
