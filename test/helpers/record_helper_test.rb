require 'test_helper'

include RecordHelper

class RecordHelperTest < ActionView::TestCase
  test 'clean_language case 1' do
    mock_record = stub(:eds_languages => 'English, Russian')
    controller.instance_variable_set(:@record, mock_record)

    assert_equal(['English', 'Russian'], controller.clean_language)
  end

  test 'clean_language case 2' do
    mock_record = stub(:eds_languages => ['English', 'Russian'])
    controller.instance_variable_set(:@record, mock_record)

    assert_equal(['English', 'Russian'], controller.clean_language)
  end

  test 'clean_language case 3' do
    mock_record = stub(:eds_languages => 'English')
    controller.instance_variable_set(:@record, mock_record)

    assert_equal(['English'], controller.clean_language)
  end

  test 'clean_language case 4' do
    mock_record = stub(:eds_languages => ['English'])
    controller.instance_variable_set(:@record, mock_record)

    assert_equal(['English'], controller.clean_language)
  end

  test 'clean_affiliations' do
    affiliations = <<-DOC
    <relatesTo>1</relatesTo>Small
            Systems Laboratory, Department of Mechanical Engineering, Worcester Polytechnic
            Institute, Worcester, MA 01532, USA
DOC
    affiliations = affiliations.gsub(/\s+/, " ").strip
    mock_record = stub(:eds_author_affiliations => affiliations)
    controller.instance_variable_set(:@record, mock_record)

    assert_equal(['Small Systems Laboratory, Department of Mechanical Engineering, Worcester Polytechnic Institute, Worcester, MA 01532, USA'],
                  controller.clean_affiliations)

  end

  test 'clean_other_titles' do
    titles = <<-DOC
    <searchLink fieldCode="TI" term="%22Jungle+capitalists%22">
    Jungle capitalists</searchLink>
DOC
    titles = titles.gsub(/\s+/, " ").strip
    mock_record = stub(:eds_other_titles => titles)
    controller.instance_variable_set(:@record, mock_record)

    assert_equal(['Jungle capitalists'],
                  controller.clean_other_titles)

  end
end
