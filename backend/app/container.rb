# frozen_string_literal: true

require 'singleton'

module MemoApp
  class Container
    include Singleton

    attr_reader :note_repository, :tag_repository, :daily_page_repository, :job_queue

    def self.resolve
      instance
    end

    def self.setup!
      resolve.setup!
    end

    def setup!
      @note_repository ||= Repositories::NoteRepository.new
      @tag_repository ||= Repositories::TagRepository.new
      @daily_page_repository ||= Repositories::DailyPageRepository.new
      @job_queue ||= Jobs::AsyncQueue.new
    end
  end
end
