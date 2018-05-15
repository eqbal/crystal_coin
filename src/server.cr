require "kemal"
require "./crystal_coin"

before_all do |env|
  env.response.content_type = "application/json"
end

this_nodes_transactions = [] of Hash(String, Int64 | String)

get "/chain" do
  this_nodes_transactions.inspect
end

get "/mine" do
  "We'll mine a new Block"
end


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
