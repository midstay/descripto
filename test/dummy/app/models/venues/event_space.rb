# frozen_string_literal: true

module Venues
  class EventSpace < ApplicationRecord
    include Descripto::Associated

    described_by :setups, options: { setups: { scoped: true } }
  end
end
