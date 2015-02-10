module Blanket
  def self.stringify_keys(hash)
    hash.inject({}) {|memo,(k,v)| memo[k.to_s] = v; memo}
  end
end
