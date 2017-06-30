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

  test 'phrase match within longer string' do
    skip 'not yet implemented'
    searchterm = 'popcorn soup is good for you'
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
    skip 'not yet implemented'
    searchterm =  'blah blah UNIDO Statistics Data Portal'
    match = Hint.match(searchterm)
    assert_equal(hints(:unido), match)
  end
end
