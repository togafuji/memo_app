# frozen_string_literal: true

module MemoApp
  module Services
    class TagSuggestionService
      KEYWORDS = %w[AI 勉強 学習 仕事 健康 開発 生活 アイデア 分析 企画].freeze

      def initialize(tag_repository)
        @tags = tag_repository
      end

      def suggest_for(note)
        text = note.bullet_points.map(&:content).join(' ')
        KEYWORDS.select { |keyword| text.include?(keyword) }.map do |keyword|
          @tags.find_or_create(keyword)
        end
      end
    end
  end
end
