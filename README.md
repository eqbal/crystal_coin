# Build a Blockchain from scratch using Crystal

### Intro

### Notes 

- I want to use a productive language like [ruby](https://www.ruby-lang.org/en/) without compromising the performance. Cryptocurrency has many time consuming computations and that's why compiled languages (ex C++ and JAVA) are the languages to go. That being said I want to use a productive language so I can keep the development fun and allow better demonstration for the ideas.

- I want to use [Crystal](https://crystal-lang.org/) language. Crystal’s syntax is heavily inspired by Ruby’s, so it feels natural to read and easy to write, and has the added benefit of a lower learning curve for experienced Ruby devs. Their slogan is:

	> Fast as C, slick as Ruby
	
- If you want to know more why to use Crystal check out [this](https://medium.com/@DuroSoft/why-crystal-is-the-most-promising-programming-language-of-2018-aad669d8344f) article

- I want to use Crystal [Amber](https://github.com/amberframework/amber) framework to handle transactions, the framework is heavily inspired by Rails framework so we can build an interface (RESTful API in our case to trigger some events like send a transaction ..etc)

- In this article I'll create the cryptocurrency from scratch rather than using [DApps]() with [Truffle]() as part of [Etherium](). Why? usually it's a good idea to create your app with Etherium and DApps if you are creating a decentralized app, that being said it's not a good idea to create a cryptocurrency using Etherium. It's more secure to have your own code to do so. One way of doing that is to clone a bitcoin repo and start modifying the code or start from scratch. 

- Ethereum is not a currency. It addresses a different market than Bitcoin. But still, it is built on blockchain technology. 




## Steps 

### Create the skeleton of the app:

```ruby
% crystal init app crystal_coin
      create  crystal_coin/.gitignore
      create  crystal_coin/.editorconfig
      create  crystal_coin/LICENSE
      create  crystal_coin/README.md
      create  crystal_coin/.travis.yml
      create  crystal_coin/shard.yml
      create  crystal_coin/src/crystal_coin.cr
      create  crystal_coin/src/crystal_coin/version.cr
      create  crystal_coin/spec/spec_helper.cr
      create  crystal_coin/spec/crystal_coin_spec.cr
Initialized empty Git repository in /Users/eqbal/code/blockchain/ruby_coin/crystal_coin/.git/
```

### What’s Blockchain?

- It’s a list (chain) of blocks linked and secured by digital fingerprints (also known as crypto hashes).

- Create `src/crystal_coin/block.cr`

```ruby
require "openssl"

module CrystalCoin
  class Block

    def initialize(data : String)
      @data = data
    end

    def hash
      hash = OpenSSL::Digest.new("SHA256")
      hash.update(@data)
      hash.hexdigest
    end
  end
end

puts CrystalCoin::Block.new("Hello, Cryptos!").hash
```

```ruby
crystal_coin [master●] % crystal src/crystal_coin/block.cr
33eedea60b0662c66c289ceba71863a864cf84b00e10002ca1069bf58f9362d5
```

- Easiest way to think of it as a linked list. It's not really a linked list tho,  A linked list is only required to have a reference to the previous element, a block must have an identifier depending on the previous block’s identifier, meaning that you cannot replace a block without recomputing every single block that comes after.


