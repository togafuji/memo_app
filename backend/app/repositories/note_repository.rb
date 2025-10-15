# frozen_string_literal: true

require 'date'
require 'time'

module MemoApp
  module Repositories
    class NoteRepository
      def initialize(database)
        @database = database
      end

      def all
        records = @database.select('SELECT * FROM notes ORDER BY created_at DESC')
        records.map { |record| hydrate_note(record) }
      end

      def find(id)
        record = @database.select_one('SELECT * FROM notes WHERE id = ?', [id])
        record && hydrate_note(record)
      end

      def for_daily_page(daily_page_id)
        records = @database.select(
          'SELECT * FROM notes WHERE daily_page_id = ? ORDER BY created_at DESC',
          [daily_page_id]
        )
        records.map { |record| hydrate_note(record) }
      end

      def for_tag(tag_id)
        records = @database.select(<<~SQL, [tag_id])
          SELECT notes.*
          FROM notes
          INNER JOIN note_tags ON note_tags.note_id = notes.id
          WHERE note_tags.tag_id = ?
          ORDER BY notes.created_at DESC
        SQL
        records.map { |record| hydrate_note(record) }
      end

      def filter(date: nil, tag_id: nil)
        query = 'SELECT DISTINCT notes.* FROM notes'
        clauses = []
        params = []

        if tag_id
          query += ' INNER JOIN note_tags ON note_tags.note_id = notes.id'
          clauses << 'note_tags.tag_id = ?'
          params << tag_id
        end

        if date
          clauses << "DATE(notes.created_at) = ?"
          params << Date.parse(date).strftime('%Y-%m-%d')
        end

        query += " WHERE #{clauses.join(' AND ')}" if clauses.any?
        query += ' ORDER BY notes.created_at DESC'

        records = @database.select(query, params)
        records.map { |record| hydrate_note(record) }
      end

      def save(note)
        existing = @database.select_one('SELECT id FROM notes WHERE id = ?', [note.id])
        note.updated_at = Time.now.utc
        attributes = {
          id: note.id,
          user_id: note.user_id,
          daily_page_id: note.daily_page_id,
          title: note.title,
          summary: note.summary,
          summary_status: note.summary_status,
          created_at: (note.created_at || note.updated_at).utc.strftime('%Y-%m-%d %H:%M:%S'),
          updated_at: note.updated_at.utc.strftime('%Y-%m-%d %H:%M:%S')
        }

        if existing
          @database.update('notes', attributes.except(:id, :created_at), where: { id: note.id })
        else
          @database.insert('notes', attributes)
        end

        replace_bullet_points(note)
        replace_tag_assignments(note)
        note
      end

      def update_summary(note_id, summary:, status: 'COMPLETED')
        record = @database.select_one('SELECT * FROM notes WHERE id = ?', [note_id])
        return unless record

        now = Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
        @database.update('notes', { summary: summary, summary_status: status, updated_at: now }, where: { id: note_id })
        hydrate_note(record.merge(summary: summary, summary_status: status, updated_at: now))
      end

      private

      def hydrate_note(record)
        Entities::Note.new(
          id: record[:id],
          user_id: record[:user_id],
          daily_page_id: record[:daily_page_id],
          title: record[:title],
          summary: record[:summary],
          summary_status: record[:summary_status],
          created_at: parse_time(record[:created_at]),
          updated_at: parse_time(record[:updated_at]),
          bullet_points: load_bullet_points(record[:id]),
          tags: load_tag_assignments(record[:id])
        )
      end

      def load_bullet_points(note_id)
        records = @database.select(
          'SELECT * FROM bullet_points WHERE note_id = ? ORDER BY position ASC',
          [note_id]
        )
        records.map do |bp|
          Entities::BulletPoint.new(
            id: bp[:id],
            note_id: bp[:note_id],
            position: bp[:position],
            content: bp[:content]
          )
        end
      end

      def load_tag_assignments(note_id)
        records = @database.select(<<~SQL, [note_id])
          SELECT tags.id, tags.name, tags.similarity_group, note_tags.weight
          FROM note_tags
          INNER JOIN tags ON tags.id = note_tags.tag_id
          WHERE note_tags.note_id = ?
          ORDER BY note_tags.weight DESC
        SQL
        records.map do |row|
          Entities::TagAssignment.new(
            id: row[:id],
            name: row[:name],
            similarity_group: row[:similarity_group],
            weight: row[:weight]
          )
        end
      end

      def replace_bullet_points(note)
        @database.delete('bullet_points', where: { note_id: note.id })
        note.bullet_points.each do |bp|
          @database.insert('bullet_points', {
                              id: bp.id,
                              note_id: note.id,
                              position: bp.position,
                              content: bp.content
                            })
        end
      end

      def replace_tag_assignments(note)
        @database.delete('note_tags', where: { note_id: note.id })
        note.tags.each do |assignment|
          @database.insert('note_tags', {
                              note_id: note.id,
                              tag_id: assignment.id,
                              weight: assignment.weight
                            })
        end
      end

      def parse_time(value)
        return value if value.is_a?(Time)

        Time.parse(value.to_s).utc
      end
    end
  end
end
