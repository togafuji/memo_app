# frozen_string_literal: true

module MemoApp
  module GraphQL
    class Schema < ::GraphQL::Schema
      query Types::QueryType
      mutation Types::MutationType
      subscription Types::SubscriptionType

      use ::GraphQL::Subscriptions::ActionCableSubscriptions if defined?(::GraphQL::Subscriptions::ActionCableSubscriptions)
      use ::GraphQL::Subscriptions::MemorySubscriptions
    end
  end
end
