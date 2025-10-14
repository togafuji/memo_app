# frozen_string_literal: true

module MemoApp
  module GraphQL
    module Types
      class QueryType < BaseObject
        field :notes, [NoteType], null: false do
          argument :date, GraphQL::Types::ISO8601Date, required: false
          argument :tag_id, ID, required: false
        end

        field :note, NoteType, null: true do
          argument :id, ID, required: true
        end

        field :daily_pages, [DailyPageType], null: false do
          argument :range_start, GraphQL::Types::ISO8601Date, required: false
          argument :range_end, GraphQL::Types::ISO8601Date, required: false
        end

        field :tags, [TagType], null: false

        def notes(date: nil, tag_id: nil)
          service.list_notes(date: date, tag_id: tag_id)
        end

        def note(id:)
          service.note(id)
        end

        def daily_pages(range_start: nil, range_end: nil)
          service.list_daily_pages(range_start: range_start&.to_s, range_end: range_end&.to_s).map do |page, notes|
            page.define_singleton_method(:notes) { notes }
            page
          end
        end

        def tags
          service.tags
        end

        private

        def service
          @service ||= MemoApp::Services::NoteService.new
        end
      end
    end
  end
end
