# frozen_string_literal: true

module MemoApp
  module GraphQL
    module Types
      class MutationType < BaseObject
        field :create_note, NotePayloadType, null: false do
          argument :input, CreateNoteInputType, required: true
        end

        field :request_summary, NotePayloadType, null: false do
          argument :note_id, ID, required: true
        end

        def create_note(input:)
          note = service.create_note(
            title: input[:title],
            entry_date: input[:entry_date].to_s,
            bullet_points: input[:bullet_points],
            tag_names: input[:tag_names]
          )
          { note: note }
        rescue StandardError => e
          raise GraphQL::ExecutionError, e.message
        end

        def request_summary(note_id:)
          note = service.request_summary(note_id)
          raise GraphQL::ExecutionError, 'ノートが見つかりません' unless note

          { note: note }
        end

        private

        def service
          @service ||= MemoApp::Services::NoteService.new
        end
      end
    end
  end
end
