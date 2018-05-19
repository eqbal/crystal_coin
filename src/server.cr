require "kemal"
require "uuid"

require "./crystal_coin"

before_all do |env|
  env.response.content_type = "application/json"
end

blockchain = CrystalCoin::Blockchain.new

# Generate a globally unique address for this node
node_identifier = UUID.random.to_s

get "/chain" do
  #this_nodes_transactions.inspect
end

get "/mine" do
  "We'll mine a new Block"
end

get "/pending" do
  "#{blockchain.uncommitted_transactions}"
end

post "/transactions/new" do |env|

  transaction = CrystalCoin::Block::Transaction.new(
    from: env.params.json["from"].as(String),
    to:  env.params.json["to"].as(String),
    amount:  env.params.json["amount"].as(Int64)

  )

  blockchain.add_transaction(transaction)

  "Transaction #{transaction.inspect} has been added to the node"
end

Kemal.run
