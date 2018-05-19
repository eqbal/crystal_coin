require "uri"

module CrystalCoin
  module Consensus
    private def register_node(address)
      uri = URI.parse(address)
      node_address = uri.host
      @nodes.add(node_address)
    rescue
      raise "Invalid URL"
    end
  end
end
