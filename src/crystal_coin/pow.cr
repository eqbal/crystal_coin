require "openssl"

def hash(data)
  hash = OpenSSL::Digest.new("SHA256")
  hash.update(data)
  hash.hexdigest
end

x = 5
y = 0

while hash((x*y).to_s)[0..1] != "00"
  y += 1
end

puts "The solution is y = #{y}"
puts "Hash(#{x}*#{y}) = #{hash((x*y).to_s)}"
