# frozen_string_literal: true

module MemoApp
  module Entities
    TagAssignment = Struct.new(
      :id,
      :name,
      :similarity_group,
      :weight,
      keyword_init: true
    )
  end
end
