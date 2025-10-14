# frozen_string_literal: true

module MemoApp
  module Jobs
    class AsyncQueue
      def initialize
        @queue = Queue.new
        @worker = Thread.new do
          Thread.current.name = 'memo-app-worker'
          loop do
            job = @queue.pop
            break if job == :shutdown

            begin
              job.call
            rescue StandardError => e
              warn "[AsyncQueue] Job failed: #{e.message}\n#{e.backtrace&.first(3)&.join('\n')}"
            end
          end
        end
      end

      def enqueue(&block)
        @queue << block
      end

      def shutdown
        @queue << :shutdown
        @worker.join
      end
    end
  end
end
