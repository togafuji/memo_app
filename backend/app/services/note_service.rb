# frozen_string_literal: true

require 'date'

module MemoApp
  module Services
    class NoteService
      DEFAULT_USER_ID = 'user-1'

      def initialize(container: MemoApp::Container.resolve)
        @notes = container.note_repository
        @tags = container.tag_repository
        @daily_pages = container.daily_page_repository
        @queue = container.job_queue
        @summary_generator = SummaryGenerator.new
        @tag_suggester = TagSuggestionService.new(@tags)
      end

      def create_note(title:, entry_date:, bullet_points:, tag_names:, user_id: DEFAULT_USER_ID)
        raise ArgumentError, 'title is required' if title.blank?

        page = @daily_pages.ensure_page(user_id: user_id, entry_date: entry_date)
        now = Time.now.utc
        note = Entities::Note.new(
          id: SecureRandom.uuid,
          user_id: user_id,
          daily_page_id: page.id,
          title: title,
          summary: nil,
          summary_status: 'PENDING',
          created_at: now,
          updated_at: now,
          bullet_points: build_bullet_points(bullet_points),
          tags: []
        )
        note.bullet_points.each { |bp| bp.note_id = note.id }

        assignments = ensure_tag_assignments(tag_names, note)
        note.tags = assignments
        @notes.save(note)
        note
      end

      def request_summary(note_id)
        note = @notes.find(note_id)
        return unless note

        note.summary_status = 'PROCESSING'
        @notes.save(note)
        @queue.enqueue do
          summary = @summary_generator.generate(note)
          updated_note = @notes.update_summary(note.id, summary: summary, status: 'COMPLETED')
          MemoApp::GraphQL::Schema.subscriptions.trigger('summaryUpdated', { note_id: note.id }, updated_note) if defined?(MemoApp::GraphQL::Schema)
        end
        note
      end

      def list_daily_pages(range_start: nil, range_end: nil)
        start_date = range_start&.then { |value| Date.parse(value.to_s) }
        end_date = range_end&.then { |value| Date.parse(value.to_s) }
        pages = @daily_pages.all
        pages.select! do |page|
          (!start_date || page.entry_date >= start_date) && (!end_date || page.entry_date <= end_date)
        end
        pages.sort_by!(&:entry_date).reverse
        pages.map do |page|
          notes = @notes.for_daily_page(page.id).sort_by(&:created_at).reverse
          [page, notes]
        end
      end

      def list_notes(date: nil, tag_id: nil)
        @notes.filter(date: date, tag_id: tag_id).sort_by(&:created_at).reverse
      end

      def note(id)
        @notes.find(id)
      end

      def tags
        @tags.all
      end

      private

      def build_bullet_points(bullet_points)
        bullet_points
          .select { |bp| bp[:content].present? }
          .sort_by { |bp| bp[:position] }
          .map do |bp|
            Entities::BulletPoint.new(
              id: SecureRandom.uuid,
              note_id: nil,
              position: bp[:position],
              content: bp[:content]
            )
          end
      end

      def ensure_tag_assignments(tag_names, note)
        tags = @tags.ensure_tags(tag_names)
        auto_tags = @tag_suggester.suggest_for(note)
        (tags + auto_tags).uniq { |tag| tag.name }.map.with_index do |tag, index|
          Entities::TagAssignment.new(
            id: tag.id,
            name: tag.name,
            similarity_group: tag.similarity_group,
            weight: (auto_tags.include?(tag) ? 0.9 - index * 0.05 : 0.7 - index * 0.05)
          )
        end
      end
    end
  end
end
