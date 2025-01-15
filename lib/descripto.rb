# frozen_string_literal: true

require_relative 'descripto/engine'
require_relative 'descripto/version'
require_relative 'descripto/associated'

require 'active_support'

module Descripto
  mattr_accessor :model_parent_class, default: 'ApplicationRecord'
  mattr_accessor :descriptions_table_name, default: 'descriptions'
  mattr_accessor :descriptives_table_name, default: 'descriptives'
end
