# frozen_string_literal: true

require 'singleton'

require_relative 'persistence/database'

module MemoApp
  class Container
    include Singleton

    attr_reader :note_repository, :tag_repository, :daily_page_repository, :job_queue, :database

    def self.resolve
      instance
    end

    def self.setup!
      resolve.setup!
    end

    def setup!
      @database ||= Persistence::Database.new
      @note_repository ||= Repositories::NoteRepository.new(@database)
      @tag_repository ||= Repositories::TagRepository.new(@database)
      @daily_page_repository ||= Repositories::DailyPageRepository.new(@database)
      @job_queue ||= Jobs::AsyncQueue.new
    end
  end
end
