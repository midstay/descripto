# frozen_string_literal: true

require_relative "descripto/version"
require_relative "descripto/associated"

module Descripto
  class Error < StandardError; end

  class Engine < ::Rails::Engine
    isolate_namespace Descripto
  end

  # Your code goes here...
end
