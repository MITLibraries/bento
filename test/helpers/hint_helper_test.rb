require 'test_helper'

class HintHelperTest < ActionView::TestCase
  setup do
    @cached_env_hint_sources = ENV['HINT_SOURCES']
  end

  teardown do
    ENV['HINT_SOURCES'] = @cached_env_hint_sources
  end

  test 'data_type' do
    ENV['HINT_SOURCES'] = 'source1'
    Hint.create!(title: 't', url: 'u', fingerprint: 'fp', source: 'source1')
    @hint = Hint.match('fp')
    assert_equal(data_type, 'Hint_source1')
  end

  test 'display_types' do
    ENV['HINT_SOURCES'] = 'custom,source1'

    # displays Popular result from custom source type
    Hint.create!(title: 't', url: 'u', fingerprint: 'fp1', source: 'custom')
    @hint = Hint.match('fp1')
    assert_equal(display_type, 'Popular result')

    # displays other text from non-custom source type
    Hint.create!(title: 't', url: 'u', fingerprint: 'fp2', source: 'source1')
    @hint = Hint.match('fp2')
    assert_equal(display_type, 'Were you looking for...')
  end

  test 'hint_link' do
    Hint.create!(title: 't', url: 'u', fingerprint: 'fp1', source: 'custom')
    @hint = Hint.match('fp1')

    # can display a link using the hint.title as link_text
    assert_equal(hint_link(@hint.title),
                 '<a data-type="Hint_custom" href="u">t</a>')

    # can display a link using the hint url as link_text
    assert_equal(hint_link(@hint.url),
                 '<a data-type="Hint_custom" href="u">u</a>')
  end
end
