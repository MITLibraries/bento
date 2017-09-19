require 'test_helper'

class RainbowTestClass
  include Rainbows
  include RecordHelper # needed to supply clean_keywords
end

class RainbowConcernTest < MiniTest::Test
  def setup
    @Rainbows = RainbowTestClass.new
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ normalize_keywords ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def test_normalize_keywords
    @Rainbows.instance_variable_set(:@keywords, ['Gender Identities'])

    kw = @Rainbows.normalize_keywords
    assert kw.present?
    assert_equal(kw.map(&:downcase), kw)
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ normalize_subjects ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def test_that_subjects_downcase
    @Rainbows.instance_variable_set(:@subjects, ['Capitalized'])

    subj = @Rainbows.normalize_subjects
    assert subj.present?
    assert_equal(subj.map(&:downcase), subj)
  end

  def test_that_subjects_replace_ampersands
    @Rainbows.instance_variable_set(:@subjects, ['this & that'])

    subj = @Rainbows.normalize_subjects
    assert subj.present?
    assert_equal(['this and that'], subj)
  end

  def test_that_subjects_throw_out_subdivisions
    @Rainbows.instance_variable_set(:@subjects,
                                    ['LCSH--may subdivide geographically'])

    subj = @Rainbows.normalize_subjects
    assert subj.present?
    assert_equal(['lcsh'], subj)
  end

  def test_that_subjects_strip_whitespace
    @Rainbows.instance_variable_set(:@subjects, ['whitespace '])

    subj = @Rainbows.normalize_subjects
    assert subj.present?
    assert_equal(['whitespace'], subj)
  end

  def test_that_subjects_strip_whitespace_when_subdivided
    @Rainbows.instance_variable_set(:@subjects,
                                    ['LCSH -- may subdivide geographically'])

    subj = @Rainbows.normalize_subjects
    assert subj.present?
    assert_equal(['lcsh'], subj)
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ pride ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def test_that_pride_true_with_good_keyword
    @Rainbows.instance_variable_set(:@subjects, '')
    @Rainbows.instance_variable_set(:@keywords, ['gender identities'])

    assert @Rainbows.pride?
  end

  def test_that_pride_true_with_good_subject
    @Rainbows.instance_variable_set(:@record, nil)
    @Rainbows.instance_variable_set(:@subjects,
                                    ['butch and femme (lesbian culture)'])

    assert @Rainbows.pride?
  end

  def test_that_pride_true_with_good_subject_and_keyword
    @Rainbows.instance_variable_set(:@keywords, ['gender identities'])
    @Rainbows.instance_variable_set(:@subjects,
                                    ['butch and femme (lesbian culture)'])

    assert @Rainbows.pride?
  end

  def test_that_pride_false_without_subject_or_keyword
    @Rainbows.instance_variable_set(:@keywords, ['no rainbows'])
    @Rainbows.instance_variable_set(:@subjects,
                                    ['extremely straight and cis people'])

    # assert_not is unavailable since this subclasses MiniTest::Test, not Rails
    # testing stuff.
    assert !@Rainbows.pride?
  end
end
