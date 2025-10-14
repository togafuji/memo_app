# frozen_string_literal: true

module MemoApp
  module Entities
    Tag = Struct.new(
      :id,
      :name,
      :similarity_group,
      :embedding,
      keyword_init: true
    )
  end
end
