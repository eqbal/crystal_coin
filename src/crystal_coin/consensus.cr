require "uri"

module CrystalCoin
  module Consensus
    def register_node(address : String)
      uri = URI.parse(address)
      node_address = "#{uri.scheme}:://#{uri.host}"
      node_address = "#{node_address}:#{uri.port}" unless uri.port.nil?
      @nodes.add(node_address)
    rescue
      raise "Invalid URL"
    end
  end
end
