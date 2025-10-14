# frozen_string_literal: true

module MemoApp
  module GraphQL
    module Types
      class BulletPointInputType < BaseInputObject
        argument :position, Integer, required: true
        argument :content, String, required: true
      end
    end
  end
end
