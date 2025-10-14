# frozen_string_literal: true

module MemoApp
  module GraphQL
    module Types
      class TagType < BaseObject
        field :id, ID, null: false
        field :name, String, null: false
        field :similarity_group, Integer, null: false
        field :weight, Float, null: true
      end
    end
  end
end
