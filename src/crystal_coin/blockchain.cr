require "./block"
require "./transaction"

module CrystalCoin
  class Blockchain
    getter chain
    getter uncommited_transactions

    def initialize
      @chain = [ Block.first ]
      @uncommited_transactions = [] of Block::Transaction
    end

    def add_transaction(transaction)
      @uncommited_transactions << transaction
    end

    def mine
      # to be implemented
      # raise "nothing to mine" if @uncommited_transactions.empty?
      # new_block = Block.new(previous_block: @chain.last, transactions: @uncommited_transactions)
      # @chain << new_block
      # @uncommited_transactions = []
    end
  end
end

transaction = CrystalCoin::Block::Transaction.new("eki", "ahmad", 11)
blockchain = CrystalCoin::Blockchain.new
p blockchain
blockchain.add_transaction(transaction)
p blockchain

