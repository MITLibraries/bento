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
#  source      :string           not null
#

require 'test_helper'

class HintTest < ActiveSupport::TestCase

  setup do
    @cached_env_hint_sources = ENV['HINT_SOURCES']
  end

  teardown do
    ENV['HINT_SOURCES'] = @cached_env_hint_sources
  end

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

  test 'match respects source priority' do
    ENV['HINT_SOURCES'] = 'custom,aleph'

    match = Hint.match('of science web')
    assert_equal('custom', match.source)

    hints(:webofscience).destroy
    match = Hint.match('of science web')
    assert_equal('aleph', match.source)
  end

  test 'Hint has default sources if env not set' do
    ENV.delete('HINT_SOURCES')

    assert_equal(['custom'], Hint.sources)
  end

  test 'Hint matches custom if env not set' do
    ENV.delete('HINT_SOURCES')

    match = Hint.match('of science web')
    assert_equal('custom', match.source)
  end

  test 'hint not matched if source not in env' do
    ENV['HINT_SOURCES'] = 'custom'

    # There is a hint in the fixture with this fingerprint, but only one, and
    # its source is aleph, so it should not be matched.
    match = Hint.match('pubmed')
    assert_nil(match)
  end

  # --- Tests of fingerprinting ---
  test 'fingerprinting distinguishes types of C' do
    # We actually want C, C++, and C# to be distinguished, even though
    # the default fingerprinting algorithm would render them all the same.
    # These are common search terms and users will not accept an "Introduction
    # to C" as a valid result when they are searching for an "Introduction to
    # C++".
    assert_not_equal(Hint.fingerprint('C'), Hint.fingerprint('C++'))
    assert_not_equal(Hint.fingerprint('C'), Hint.fingerprint('C#'))
    assert_not_equal(Hint.fingerprint('C++'), Hint.fingerprint('C#'))

    assert_not_equal(Hint.fingerprint('Introduction to C'),
                     Hint.fingerprint('Introduction to C++'))
    assert_not_equal(Hint.fingerprint('Introduction to C'),
                     Hint.fingerprint('Introduction to C#'))
    assert_not_equal(Hint.fingerprint('Introduction to C#'),
                     Hint.fingerprint('Introduction to C++'))
  end

  test 'distinguishing c-type languages does not preserve other features' do
    # We're distinguishing C, C++, and C#, but we don't want to throw out all
    # of our other fingerprinting rules to get there.
    assert_equal(Hint.fingerprint('introduction to c++'),
                 Hint.fingerprint('Introduction to C++'))

    assert_equal(Hint.fingerprint('Introdüction to C++'),
                 Hint.fingerprint('Introduction to C++'))

    assert_equal(Hint.fingerprint(' Introduction to C++'),
                 Hint.fingerprint('Introduction to C++'))

    assert_equal(Hint.fingerprint('C++: an introduction'),
                 Hint.fingerprint('C++ an introduction'))

    assert_equal(Hint.fingerprint('C++ C++'),
                 Hint.fingerprint('C++'))
  end

  test 'distinguishing c-type languages does not prevent punctuation removal' do
    # We want to distinguish C++, C#, and C, but that doesn't mean we should
    # ignore ALL punctuation after the letter C.
    print = Hint.fingerprint('milosevic, slobodan')
    assert_equal(print, 'milosevic slobodan')
  end

  test 'fingerprint strips leading and trailing spaces' do
    print = Hint.fingerprint(' bento ')
    assert_equal(print, 'bento')

    print = Hint.fingerprint('bento ')
    assert_equal(print, 'bento')

    print = Hint.fingerprint(' bento')
    assert_equal(print, 'bento')
  end

  test 'fingerprint downcases' do
    print = Hint.fingerprint('bento')
    assert_equal(print, 'bento')

    print = Hint.fingerprint('Bento')
    assert_equal(print, 'bento')

    print = Hint.fingerprint('BENTO')
    assert_equal(print, 'bento')
  end

  test 'fingerprint removes punctuation' do
    print = Hint.fingerprint('bento!')
    assert_equal(print, 'bento')

    print = Hint.fingerprint('bento,')
    assert_equal(print, 'bento')

    print = Hint.fingerprint('bento#')
    assert_equal(print, 'bento')
  end

  test 'fingerprint removes + when not part of C++' do
    print = Hint.fingerprint('b+ento')
    assert_equal(print, 'bento')

    print = Hint.fingerprint('bento++')
    assert_equal(print, 'bento')
  end

  test 'fingerprint removes # when not part of C#' do
    print = Hint.fingerprint('b#ento')
    assert_equal(print, 'bento')

    print = Hint.fingerprint('d#')
    assert_equal(print, 'd')
  end

  test 'fingerprint removes duplicates' do
    print = Hint.fingerprint('bento bento')
    assert_equal(print, 'bento')

    print = Hint.fingerprint('bento is bento')
    assert_equal(print, 'bento is')
  end

  test 'fingerprint alphabetizes tokens' do
    print = Hint.fingerprint('web of science')
    assert_equal(print, 'of science web')
  end

  test 'fingerprint normalizes non-ascii characters' do
    print = Hint.fingerprint('bénto')
    assert_equal(print, 'bento')

    print = Hint.fingerprint('bentö')
    assert_equal(print, 'bento')
  end

  test 'match returns true based on fingerprint equivalence' do
    match = Hint.match('web of science')
    assert_equal(hints(:webofscience), match)

    match = Hint.match('Web of science')
    assert_equal(hints(:webofscience), match)

    match = Hint.match('science, web of ')
    assert_equal(hints(:webofscience), match)

    match = Hint.match('WEB web web OF of of SCIENCE science science')
    assert_equal(hints(:webofscience), match)

    match = Hint.match('scíënçe!, WEB OF ')
    assert_equal(hints(:webofscience), match)
  end

  test 'duplicates via create for a single source result in db error' do
    Hint.create!(title: 't', url: 'u', fingerprint: 'fp', source: 'custom')
    assert_raise ActiveRecord::RecordInvalid do
      Hint.create!(title: 't', url: 'u2', fingerprint: 'fp', source: 'custom')
    end
  end

  test 'duplicates via upsert for a single source result in an update' do
    initial_count = Hint.count
    Hint.upsert(title: 't', url: 'u', fingerprint: 'fp', source: 'custom')
    assert_equal(Hint.count, initial_count + 1)
    assert_equal(Hint.match('fp').url, 'u')
    Hint.upsert(title: 't', url: 'u2', fingerprint: 'fp', source: 'custom')
    assert_equal(Hint.count, initial_count + 1)
    assert_equal(Hint.match('fp').url, 'u2')
  end

  test 'duplicates fingerprints for different sources are allowed' do
    ENV['HINT_SOURCES'] = 'source1,source2'
    initial_count = Hint.count
    Hint.create!(title: 't', url: 'u', fingerprint: 'fp', source: 'source1')
    Hint.create!(title: 't', url: 'u', fingerprint: 'fp', source: 'source2')
    assert_equal(Hint.count, initial_count + 2)
  end
end
