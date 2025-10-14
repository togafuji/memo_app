# frozen_string_literal: true

require 'monitor'

module MemoApp
  module Repositories
    class TagRepository
      def initialize
        @tags = {}
        @monitor = Monitor.new
      end

      def all
        @tags.values.map { |tag| deep_dup(tag) }
      end

      def find(id)
        @monitor.synchronize { deep_dup(@tags[id]) }
      end

      def find_by_name(name)
        @monitor.synchronize do
          @tags.values.find { |tag| tag.name.casecmp?(name) }
        end
      end

      def ensure_tags(names)
        names.map { |name| find_or_create(name) }
      end

      def find_or_create(name)
        @monitor.synchronize do
          existing = @tags.values.find { |tag| tag.name.casecmp?(name) }
          return deep_dup(existing) if existing

          tag = Entities::Tag.new(
            id: SecureRandom.uuid,
            name: name,
            similarity_group: rand(1..8),
            embedding: generate_embedding(name)
          )
          @tags[tag.id] = tag
          deep_dup(tag)
        end
      end

      private

      def generate_embedding(name)
        seed = name.each_byte.sum
        Array.new(8) { |i| ((seed * (i + 3)) % 100) / 100.0 }
      end

      def deep_dup(tag)
        return if tag.nil?

        Entities::Tag.new(**tag.to_h.deep_dup)
      end
    end
  end
end
