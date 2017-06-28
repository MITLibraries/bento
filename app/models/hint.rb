class Hint < ApplicationRecord
  has_many :matches

  def self.match(searchterm)
    Match.all.map do |m|
      next unless searchterm.include?(m.match)
      m.hint
    end.compact.first
  end
end
