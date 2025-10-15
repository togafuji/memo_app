# frozen_string_literal: true

require 'json'
require 'time'

module MemoApp
  module Repositories
    class TagRepository
      def initialize(database)
        @database = database
      end

      def all
        records = @database.select('SELECT * FROM tags ORDER BY name ASC')
        records.map { |record| build_entity(record) }
      end

      def find(id)
        record = @database.select_one('SELECT * FROM tags WHERE id = ?', [id])
        record && build_entity(record)
      end

      def find_by_name(name)
        record = @database.select_one('SELECT * FROM tags WHERE LOWER(name) = ?', [name.downcase])
        record && build_entity(record)
      end

      def ensure_tags(names)
        names.map { |name| find_or_create(name) }
      end

      def find_or_create(name)
        existing = find_by_name(name)
        return existing if existing

        now = Time.now.utc
        tag = Entities::Tag.new(
          id: SecureRandom.uuid,
          name: name,
          similarity_group: rand(1..8),
          embedding: generate_embedding(name)
        )
        @database.insert('tags', {
                            id: tag.id,
                            name: tag.name,
                            similarity_group: tag.similarity_group,
                            embedding: JSON.dump(tag.embedding),
                            created_at: now,
                            updated_at: now
                          })
        tag
      end

      private

      def generate_embedding(name)
        seed = name.each_byte.sum
        Array.new(8) { |i| ((seed * (i + 3)) % 100) / 100.0 }
      end

      def build_entity(record)
        Entities::Tag.new(
          id: record[:id],
          name: record[:name],
          similarity_group: record[:similarity_group],
          embedding: JSON.parse(record[:embedding])
        )
      end
    end
  end
end
