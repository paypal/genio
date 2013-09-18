require 'logger'

module Genio
  class << self
    attr_accessor :logger
  end
  self.logger = Logger.new(STDERR)

  module Logging
    def logger
      Genio.logger
    end
  end
end
