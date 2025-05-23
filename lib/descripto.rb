# frozen_string_literal: true

require_relative "descripto/associated"
require_relative "descripto/version"

require "action_controller/railtie"
require "rails/engine"

module Descripto
  mattr_accessor :parent_model_class, default: "ApplicationRecord"

  class Error < StandardError; end

  class Engine < Rails::Engine
    isolate_namespace Descripto
  end

  # Your code goes here...
end
