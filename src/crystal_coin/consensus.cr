require "uri"
require "http/client"

module CrystalCoin
  module Consensus
    def register_node(address : String)
      uri = URI.parse(address)
      node_address = "#{uri.scheme}://#{uri.host}"
      node_address = "#{node_address}:#{uri.port}" unless uri.port.nil?
      @nodes.add(node_address)
    rescue
      raise "Invalid URL"
    end

    def resolve
      @nodes.each do |node|
        node_chain = parse_chain(node)
        return unless node_chain.size > @chain.size
        return unless valid_chain?(node_chain)
        @chain = node_chain
        p "Succefully updated the chain"
      rescue IO::Timeout
        puts "Timeout!"
      end
    end

    private def parse_chain(node : String)
      node_url = URI.parse("#{node}/chain")
      node_chain = HTTP::Client.get(node_url)

      node_chain = JSON.parse(node_chain.body)["chain"].to_json
      node_chain = Array(CrystalCoin::Block).from_json(node_chain)
    end

    private def valid_chain?(node_chain)
      previous_hash = "0"

      node_chain.each do |block|
        current_block_hash = block.current_hash
        block.recalculate_hash

        return false if current_block_hash != block.current_hash
        return false if previous_hash != block.previous_hash
        previous_hash = block.current_hash
      end

      return true
    end
  end
end
