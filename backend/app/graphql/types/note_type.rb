# frozen_string_literal: true

module MemoApp
  module GraphQL
    module Types
      class NoteType < BaseObject
        field :id, ID, null: false
        field :title, String, null: false
        field :summary, String, null: true
        field :summary_status, SummaryStatusEnum, null: false
        field :created_at, GraphQL::Types::ISO8601DateTime, null: false
        field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
        field :bullet_points, [BulletPointType], null: false
        field :tags, [TagType], null: false
      end
    end
  end
end
