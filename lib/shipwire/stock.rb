module Shipwire
  class Stock < Api
    def self.list(params = {})
      request(:get, 'stock', params: params)
    end
  end
end
