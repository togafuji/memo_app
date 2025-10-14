# frozen_string_literal: true

module MemoApp
  module GraphQL
    module Types
      class CreateNoteInputType < BaseInputObject
        argument :title, String, required: true
        argument :entry_date, GraphQL::Types::ISO8601Date, required: true
        argument :bullet_points, [BulletPointInputType], required: true
        argument :tag_names, [String], required: false, default_value: []
      end
    end
  end
end
