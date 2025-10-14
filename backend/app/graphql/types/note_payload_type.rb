# frozen_string_literal: true

module MemoApp
  module GraphQL
    module Types
      class NotePayloadType < BaseObject
        field :note, NoteType, null: false
      end
    end
  end
end
