module Gera
  # @abstract
  class ApplicationRecord < ::ApplicationRecord
    self.abstract_class = true
  end
end