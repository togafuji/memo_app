# frozen_string_literal: true

require 'monitor'
require 'date'

module MemoApp
  module Repositories
    class NoteRepository
      def initialize
        @notes = {}
        @monitor = Monitor.new
      end

      def all
        @notes.values.map { |note| deep_dup(note) }
      end

      def find(id)
        @monitor.synchronize { deep_dup(@notes[id]) }
      end

      def for_daily_page(daily_page_id)
        @monitor.synchronize do
          @notes.values.select { |note| note.daily_page_id == daily_page_id }.map { |note| deep_dup(note) }
        end
      end

      def for_tag(tag_id)
        @monitor.synchronize do
          @notes.values.select { |note| note.tags.any? { |tag| tag.id == tag_id } }.map { |note| deep_dup(note) }
        end
      end

      def filter(date: nil, tag_id: nil)
        @monitor.synchronize do
          @notes.values.select do |note|
            matches_date = date.nil? || note.created_at.to_date == Date.parse(date)
            matches_tag = tag_id.nil? || note.tags.any? { |tag| tag.id == tag_id }
            matches_date && matches_tag
          end.map { |note| deep_dup(note) }
        end
      end

      def save(note)
        @monitor.synchronize do
          note.updated_at = Time.now.utc
          @notes[note.id] = deep_dup(note)
        end
        note
      end

      def update_summary(note_id, summary:, status: 'COMPLETED')
        @monitor.synchronize do
          note = @notes[note_id]
          return unless note

          note.summary = summary
          note.summary_status = status
          note.updated_at = Time.now.utc
          deep_dup(note)
        end
      end

      private

      def deep_dup(note)
        return if note.nil?

        Entities::Note.new(**note.to_h.deep_dup)
      end
    end
  end
end
