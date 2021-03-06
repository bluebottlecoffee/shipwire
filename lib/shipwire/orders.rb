module Shipwire
  class Orders < Api
    def list(params = {})
      request(:get, 'orders', params: params)
    end

    def create(body)
      request(:post, 'orders', body: body)
    end

    def find(id, params = {})
      request(:get, "orders/#{id}", params: params)
    end

    def update(id, body, params = {})
      request(:put, "orders/#{id}", body: body, params: params)
    end

    def cancel(id)
      request(:post, "orders/#{id}/cancel")
    end

    def holds(id, params = {})
      request(:get, "orders/#{id}/holds", params: params)
    end

    def release(id)
      request(:post, "orders/#{id}/holds/clear")
    end

    def items(id)
      request(:get, "orders/#{id}/items")
    end

    def pieces(id)
      request(:get, "orders/#{id}/pieces")
    end

    def returns(id)
      request(:get, "orders/#{id}/returns")
    end

    def trackings(id)
      request(:get, "orders/#{id}/trackings")
    end
  end
end
