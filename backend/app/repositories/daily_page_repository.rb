# frozen_string_literal: true

require 'monitor'
require 'date'

module MemoApp
  module Repositories
    class DailyPageRepository
      def initialize
        @pages = {}
        @monitor = Monitor.new
      end

      def all
        @pages.values.map { |page| deep_dup(page) }
      end

      def find(id)
        @monitor.synchronize { deep_dup(@pages[id]) }
      end

      def find_by_date(user_id:, entry_date:)
        date = normalize(entry_date)
        @monitor.synchronize do
          @pages.values.find do |page|
            page.user_id == user_id && page.entry_date == date
          end&.yield_self { |page| deep_dup(page) }
        end
      end

      def ensure_page(user_id:, entry_date:)
        date = normalize(entry_date)
        @monitor.synchronize do
          existing = @pages.values.find do |page|
            page.user_id == user_id && page.entry_date == date
          end
          return deep_dup(existing) if existing

          page = Entities::DailyPage.new(
            id: SecureRandom.uuid,
            user_id: user_id,
            entry_date: date,
            cached_summary: nil
          )
          @pages[page.id] = page
          deep_dup(page)
        end
      end

      private

      def normalize(value)
        return value if value.is_a?(Date)

        Date.parse(value.to_s)
      end

      def deep_dup(page)
        return if page.nil?

        Entities::DailyPage.new(**page.to_h.deep_dup)
      end
    end
  end
end
