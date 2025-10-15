# frozen_string_literal: true

require 'date'
require 'time'

module MemoApp
  module Repositories
    class DailyPageRepository
      def initialize(database)
        @database = database
      end

      def all
        records = @database.select('SELECT * FROM daily_pages ORDER BY entry_date DESC')
        records.map { |attrs| build_entity(attrs) }
      end

      def find(id)
        record = @database.select_one('SELECT * FROM daily_pages WHERE id = ?', [id])
        record && build_entity(record)
      end

      def find_by_date(user_id:, entry_date:)
        date = normalize(entry_date)
        record = @database.select_one(
          'SELECT * FROM daily_pages WHERE user_id = ? AND entry_date = ?',
          [user_id, date.strftime('%Y-%m-%d')]
        )
        record && build_entity(record)
      end

      def ensure_page(user_id:, entry_date:)
        date = normalize(entry_date)
        existing = find_by_date(user_id: user_id, entry_date: date)
        return existing if existing

        now = Time.now.utc
        page = Entities::DailyPage.new(
          id: SecureRandom.uuid,
          user_id: user_id,
          entry_date: date,
          cached_summary: nil
        )
        @database.insert('daily_pages', {
                            id: page.id,
                            user_id: page.user_id,
                            entry_date: page.entry_date.strftime('%Y-%m-%d'),
                            cached_summary: page.cached_summary,
                            created_at: now,
                            updated_at: now
                          })
        page
      end

      private

      def normalize(value)
        return value if value.is_a?(Date)

        Date.parse(value.to_s)
      end

      def build_entity(record)
        Entities::DailyPage.new(
          id: record[:id],
          user_id: record[:user_id],
          entry_date: Date.parse(record[:entry_date].to_s),
          cached_summary: record[:cached_summary]
        )
      end
    end
  end
end
