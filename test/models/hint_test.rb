require 'test_helper'

class HintTest < ActiveSupport::TestCase
  test 'simple exact match' do
    searchterm = 'popcorn'
    match = Hint.match(searchterm)
    assert_equal(hints(:one), match)
  end

  test 'simple non match' do
    searchterm = 'grapes'
    match = Hint.match(searchterm)
    assert_nil(match)
  end

  test 'match on one of multiple terms' do
    searchterm = 'INDSTAT'
    match = Hint.match(searchterm)
    assert_equal(hints(:unido), match)
  end

  test 'match anywhere in the searchterm' do
    searchterm = 'I want INDSTAT to be found'
    match = Hint.match(searchterm)
    assert_equal(hints(:unido), match)
  end

  test 'phrase match within longer string if enabled' do
    searchterm = 'popcorn soup is good for you'
    # match on 'popcorn soup is good for you'
    # match on 'soup is good for you' ?
    # match on 'popcorn soup' ?
    match = Hint.match(searchterm)
    assert_equal(hints(:one), match)
  end

  # The intent of this test is to prove we can disable matching
  # of the phrase if it is not left truncated. Right now we
  # cannot do that though so we skip it. The feature seems
  # useful but has not gotten stakeholder support yet.
  test 'no phrase match mid string if not enabled' do
    skip 'not yet implemented'
    searchterm =  'soup is good popcorn'
    match = Hint.match(searchterm)
    assert_nil(match)
  end

  test 'phrase left justified in longer string when not enabled' do
    searchterm =  'blah blah UNIDO Statistics Data Portal'
    match = Hint.match(searchterm)
    assert_equal(hints(:unido), match)
  end
end
