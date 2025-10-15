# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'open3'
require 'date'
require 'time'

module MemoApp
  module Persistence
    class Database
      class Error < StandardError; end

      DEFAULT_PATH = File.expand_path('../../db/development.sqlite3', __dir__)

      attr_reader :database_path

      def initialize(database_path: ENV.fetch('DATABASE_PATH', DEFAULT_PATH))
        @database_path = database_path
        ensure_database!
      end

      def select(sql, params = [])
        output = execute(sql, params, json: true)
        return [] if output.strip.empty?

        JSON.parse(output, symbolize_names: true)
      end

      def select_one(sql, params = [])
        select(sql, params).first
      end

      def insert(table, attributes)
        columns = attributes.keys.map { |name| escape_identifier(name) }
        values = attributes.values.map { |value| quote(value) }
        run("INSERT INTO #{escape_identifier(table)} (#{columns.join(', ')}) VALUES (#{values.join(', ')});")
      end

      def update(table, attributes, where: {})
        set_clause = attributes.map { |key, value| "#{escape_identifier(key)} = #{quote(value)}" }.join(', ')
        run("UPDATE #{escape_identifier(table)} SET #{set_clause} #{build_where_clause(where)};")
      end

      def delete(table, where: {})
        run("DELETE FROM #{escape_identifier(table)} #{build_where_clause(where)};")
      end

      def execute(sql, params = [], json: false)
        statement = bind_params(sql, params)
        run(statement, json: json)
      end

      private

      def ensure_database!
        FileUtils.mkdir_p(File.dirname(database_path))
        run('PRAGMA foreign_keys = ON;')
        create_tables!
      end

      def create_tables!
        run(<<~SQL)
          CREATE TABLE IF NOT EXISTS daily_pages (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            entry_date TEXT NOT NULL,
            cached_summary TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            UNIQUE(user_id, entry_date)
          );
        SQL

        run(<<~SQL)
          CREATE TABLE IF NOT EXISTS notes (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            daily_page_id TEXT NOT NULL,
            title TEXT NOT NULL,
            summary TEXT,
            summary_status TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY(daily_page_id) REFERENCES daily_pages(id) ON DELETE CASCADE
          );
        SQL

        run(<<~SQL)
          CREATE TABLE IF NOT EXISTS bullet_points (
            id TEXT PRIMARY KEY,
            note_id TEXT NOT NULL,
            position INTEGER NOT NULL,
            content TEXT NOT NULL,
            FOREIGN KEY(note_id) REFERENCES notes(id) ON DELETE CASCADE
          );
        SQL

        run(<<~SQL)
          CREATE TABLE IF NOT EXISTS tags (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            similarity_group INTEGER NOT NULL,
            embedding TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          );
        SQL

        run(<<~SQL)
          CREATE TABLE IF NOT EXISTS note_tags (
            note_id TEXT NOT NULL,
            tag_id TEXT NOT NULL,
            weight REAL NOT NULL,
            PRIMARY KEY(note_id, tag_id),
            FOREIGN KEY(note_id) REFERENCES notes(id) ON DELETE CASCADE,
            FOREIGN KEY(tag_id) REFERENCES tags(id) ON DELETE CASCADE
          );
        SQL
      end

      def run(sql, json: false)
        statement = sql.to_s.strip
        statement = statement.end_with?(';') ? statement : "#{statement};"
        args = ['sqlite3']
        args << '-json' if json
        args << database_path
        stdout, stderr, status = Open3.capture3(*args, stdin_data: statement)
        raise Error, stderr.strip unless status.success?

        stdout
      end

      def bind_params(sql, params)
        return sql if params.empty?

        segments = sql.split('?')
        raise Error, 'parameter count mismatch' unless segments.length == params.length + 1

        result = segments.first
        params.each_with_index do |value, index|
          result += quote(value) + segments[index + 1]
        end
        result
      end

      def build_where_clause(where)
        return '' if where.nil? || where.empty?

        conditions = where.map { |key, value| "#{escape_identifier(key)} = #{quote(value)}" }
        "WHERE #{conditions.join(' AND ')}"
      end

      def escape_identifier(name)
        %("#{name.to_s.gsub('"', '""')}")
      end

      def quote(value)
        case value
        when nil
          'NULL'
        when Numeric
          value.to_s
        when TrueClass, FalseClass
          value ? '1' : '0'
        when Time
          "'#{value.utc.strftime('%Y-%m-%d %H:%M:%S')}'"
        when Date
          "'#{value.strftime('%Y-%m-%d')}'"
        else
          "'#{value.to_s.gsub("'", "''")}'"
        end
      end
    end
  end
end
