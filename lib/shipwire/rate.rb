module Shipwire
  class Rate < Api
    def self.find(body)
      request(:post, 'rate', body: body)
    end
  end
end
