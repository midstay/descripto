# frozen_string_literal: true

require_relative "descripto/associated"
require_relative "descripto/version"

require_relative "descripto/generators/install_generator"

require "action_controller/railtie"
require "rails/engine"

module Descripto
  class Error < StandardError; end

  class Engine < Rails::Engine
    isolate_namespace Descripto
  end

  # Your code goes here...
end
