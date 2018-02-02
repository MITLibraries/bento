require 'test_helper'

class ButtonMakerTest < ActiveSupport::TestCase
  setup do
    VCR.use_cassette('realtime aleph volume') do
      @item = AlephItem.new.xml_status('MIT01001019412').xpath('//items').children.first
    end
    @oclc = '123456789'
    @scan = 'true'
    bm = Class.new do
      include ButtonMaker
    end
    @button = bm.new(@item, @oclc, @scan)
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Test item properties ~~~~~~~~~~~~~~~~~~~~~~~~~~
  test 'barcode' do
    assert_equal('39080023421933', @button.instance_variable_get(:@barcode))
  end

  test 'call number' do
    assert_equal('PS3515.U274 2001', @button.instance_variable_get(:@call_number))
  end

  test 'collection' do
    assert_equal('Stacks', @button.instance_variable_get(:@collection))
  end

  test 'doc_number' do
    assert_equal('001019412', @button.instance_variable_get(:@doc_number))
  end

  test 'identifier' do
    assert_equal('0826213391', @button.instance_variable_get(:@identifier))
  end

  test 'item_sequence' do
    assert_equal('000130', @button.instance_variable_get(:@item_sequence))
  end

  test 'library' do
    assert_equal('Hayden Library', @button.instance_variable_get(:@library))
  end

  test 'oclc_number' do
    assert_equal('123456789', @button.instance_variable_get(:@oclc_number))
  end

  test 'oclc_number messy data' do
    messy_button_class = Class.new do
      include ButtonMaker
    end
    messy_button = messy_button_class.new(
      @item,
      '123456789&lt;br/&gt;947074821',
      @scan
    )
    assert_equal('123456789', messy_button.instance_variable_get(:@oclc_number))
  end

  test 'status' do
    assert_equal('In Library', @button.instance_variable_get(:@status))
  end

  test 'title' do
    assert_equal('The collected works of Langston Hughes / edited with an introduction by Arnold Rampersad.',
                  @button.instance_variable_get(:@title))
  end

  test 'z30status' do
    assert_equal('60 Day Loan', @button.instance_variable_get(:@z30status))
  end

  test 'z30status_code' do
    assert_equal('01', @button.instance_variable_get(:@z30status_code))
  end
end
