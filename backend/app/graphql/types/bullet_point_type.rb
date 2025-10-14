# frozen_string_literal: true

module MemoApp
  module GraphQL
    module Types
      class BulletPointType < BaseObject
        field :id, ID, null: false
        field :position, Integer, null: false
        field :content, String, null: false
      end
    end
  end
end
