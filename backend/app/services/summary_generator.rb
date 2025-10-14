# frozen_string_literal: true

module MemoApp
  module Services
    class SummaryGenerator
      def generate(note)
        bullet_texts = note.bullet_points.sort_by(&:position).map(&:content)
        important = bullet_texts.reject(&:blank?).first(3)
        summary = important.map.with_index(1) { |line, index| "#{index}. #{line.tr('\n', ' ')}" }.join(' / ')
        summary = summary.presence || '入力された bullet points から要約できる情報がありません。'
        summary.slice(0, 200)
      end
    end
  end
end
