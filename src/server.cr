require "kemal"
require "./crystal_coin"

get "/chain" do
  "Send the blockchain as json objects"
end

get "/mine" do
  "We'll mine a new Block"
end

post "/transactions/new" do
  "We'll add a new transaction"
end

Kemal.run
