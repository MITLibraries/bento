# == Schema Information
#
# Table name: hints
#
#  id          :integer          not null, primary key
#  title       :string           not null
#  url         :string           not null
#  fingerprint :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'stringex/core_ext'

class Hint < ApplicationRecord
  def self.match(searchterm)
    searchprint = fingerprint(searchterm)
    Hint.find_by(fingerprint: searchprint)
  end

  # This implements the OpenRefine fingerprinting algorithm. See
  # https://github.com/OpenRefine/OpenRefine/wiki/Clustering-In-Depth#fingerprint
  def self.fingerprint(searchterm)
    # Preprocess.
    searchterm.strip!
    searchterm.downcase!

    depunctuate!(searchterm)

    # Tokenize.
    term_array = searchterm.split(' ')

    # Remove duplicates and sort.
    term_array.uniq!
    term_array.sort!

    # Rejoin tokens.
    fingerprint = term_array.join(' ')

    # rubocop:disable AsciiComments
    # Normalize to ASCII (e.g. gödel and godel are liable to be intended to
    # find the same thing). (Yes, to_ascii lacks a to_ascii! equivalent,
    # but that's okay as this is the last line so we just need to return
    # output.)
    # rubocop:enable AsciiComments
    fingerprint.to_ascii
  end

  def self.depunctuate!(searchterm)
    # What's up with the regexp? We want to remove punctuation from
    # the string EXCEPT where it where it is part of the term C++ or C#
    # (as a standalone term - appearing either immediately after whitespace
    # or at the beginning of a line). Those terms are meaningfully different
    # from C, and our users frequently search for them. It turns out to be
    # hard to write a single regexp that does this without affecting any
    # other punctuation, so we pull out C++ and C#; replace all punctuation;
    # and then put them back.
    searchterm.gsub!(/[cC]\+{2}/, 'GROSSHACKCPLUSPLUS')
    searchterm.gsub!(/[cC]\#/, 'GROSSHACKCSHARP')
    searchterm.gsub!(/\p{P}|\p{S}/, '')
    searchterm.gsub!(/GROSSHACKCPLUSPLUS/, 'c++')
    searchterm.gsub!(/GROSSHACKCSHARP/, 'c#')
  end
end
