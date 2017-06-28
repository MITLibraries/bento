class Hint < ApplicationRecord
  def self.match(searchterm)
    Hint.find_by(fingerprint: searchterm)
  end
end
