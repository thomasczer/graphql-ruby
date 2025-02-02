# frozen_string_literal: true
module GraphQL
  class Query
    # This object can be `ctx` in places where there is no query
    class NullContext
      class NullWarden < GraphQL::Schema::Warden
        def visible_field?(field, ctx); true; end
        def visible_argument?(arg, ctx); true; end
        def visible_type?(type, ctx); true; end
        def visible_enum_value?(ev, ctx); true; end
        def visible_type_membership?(tm, ctx); true; end
      end

      class NullQuery
        def after_lazy(value)
          yield(value)
        end
      end

      class NullSchema < GraphQL::Schema
      end

      extend Forwardable

      attr_reader :schema, :query, :warden, :dataloader
      def_delegators GraphQL::EmptyObjects::EMPTY_HASH, :[], :fetch, :dig, :key?

      def initialize
        @query = NullQuery.new
        @dataloader = GraphQL::Dataloader::NullDataloader.new
        @schema = NullSchema
        @warden = NullWarden.new(
          GraphQL::Filter.new(silence_deprecation_warning: true),
          context: self,
          schema: @schema,
        )
      end

      def interpreter?
        true
      end

      class << self
        extend Forwardable

        def instance
          @instance ||= self.new
        end

        def_delegators :instance, :query, :warden, :schema, :interpreter?, :dataloader, :[], :fetch, :dig, :key?
      end
    end
  end
end
