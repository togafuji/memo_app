# frozen_string_literal: true

module MemoApp
  module Entities
    DailyPage = Struct.new(
      :id,
      :user_id,
      :entry_date,
      :cached_summary,
      keyword_init: true
    )
  end
end
