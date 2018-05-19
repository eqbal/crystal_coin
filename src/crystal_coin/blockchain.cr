require "./block"
require "./transaction"

module CrystalCoin
  class Blockchain
    getter chain
    getter uncommitted_transactions

    def initialize
      @chain = [ Block.first ]
      @uncommitted_transactions = [] of Block::Transaction
    end

    def add_transaction(transaction)
      @uncommitted_transactions << transaction
    end

    def mine
      # This function serves as an interface to add the pending
      # transactions to the blockchain by adding them to the block
      # and figuring out Proof of Work
      # to be implemented
      # raise "nothing to mine" if @uncommitted_transactions.empty?
      # new_block = Block.new(previous_block: @chain.last, transactions: @uncommitted_transactions)
      # @chain << new_block
      # @uncommitted_transactions = []
    end

    def add_block
      # A function that adds the block to the chain after verification
    end

  end
end
