# frozen_string_literal: true

module MemoApp
  module GraphQL
    module Types
      class SummaryStatusEnum < BaseEnum
        value 'PENDING'
        value 'PROCESSING'
        value 'COMPLETED'
      end
    end
  end
end
