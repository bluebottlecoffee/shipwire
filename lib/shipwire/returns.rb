module Shipwire
  class Returns < Api
    class << self
      def list(params = {})
        request(:get, 'returns', params: params)
      end

      def create(body)
        request(:post, 'returns', body: body)
      end

      def find(id, params = {})
        request(:get, "returns/#{id}", params: params)
      end

      def cancel(id)
        request(:post, "returns/#{id}/cancel")
      end

      def holds(id, params = {})
        request(:get, "returns/#{id}/holds", params: params)
      end

      def items(id)
        request(:get, "returns/#{id}/items")
      end

      def trackings(id)
        request(:get, "returns/#{id}/trackings")
      end

      def labels(id)
        request(:get, "returns/#{id}/labels")
      end
    end
  end
end
