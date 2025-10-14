# frozen_string_literal: true

module MemoApp
  module GraphQL
    module Types
      class DailyPageType < BaseObject
        field :id, ID, null: false
        field :entry_date, GraphQL::Types::ISO8601Date, null: false
        field :notes, [NoteType], null: false
      end
    end
  end
end
