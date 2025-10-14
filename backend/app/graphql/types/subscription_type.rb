# frozen_string_literal: true

module MemoApp
  module GraphQL
    module Types
      class SubscriptionType < BaseObject
        field :summary_updated, NoteType, null: false do
          argument :note_id, ID, required: true
        end

        def summary_updated(note_id:)
          service.note(note_id)
        end

        private

        def service
          @service ||= MemoApp::Services::NoteService.new
        end
      end
    end
  end
end
