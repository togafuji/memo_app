# frozen_string_literal: true

module MemoApp
  module Entities
    Note = Struct.new(
      :id,
      :user_id,
      :daily_page_id,
      :title,
      :summary,
      :summary_status,
      :created_at,
      :updated_at,
      :bullet_points,
      :tags,
      keyword_init: true
    )
  end
end
