require "kemal"
require "uuid"

require "./crystal_coin"

before_all do |env|
  env.response.content_type = "application/json"
end

this_node_transactions = [] of Hash(String, Int64 | String)
this_node_chain = [] of CrystalCoin::Block

# Create the genesis block
genesis_block = CrystalCoin::Block.first

# Add Genesis block to the chain
this_node_chain << genesis_block

# Generate a globally unique address for this node
node_identifier = UUID.random.to_s

get "/chain" do
  this_nodes_transactions.inspect
end

get "/mine" do
  "We'll mine a new Block"
end

# Creates a new transaction to go into the next mined Block
post "/transactions/new" do |env|
  transaction = {
    "from"   => env.params.json["from"].as(String),
    "to"     => env.params.json["to"].as(String),
    "amount" => env.params.json["amount"].as(Int64)
  }

  this_nodes_transactions << transaction

  "Transaction #{transaction} has been added to the node transactions"
end

Kemal.run
