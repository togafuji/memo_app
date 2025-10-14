# frozen_string_literal: true

require 'securerandom'
require 'json'
require 'time'

module MemoApp
  class Application
    class << self
      def boot!
        return if defined?(@booted) && @booted

        MemoApp::Container.setup!
        @booted = true
      end
    end
  end
end
