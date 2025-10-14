# frozen_string_literal: true

module MemoApp
  module Entities
    BulletPoint = Struct.new(
      :id,
      :note_id,
      :position,
      :content,
      keyword_init: true
    )
  end
end
