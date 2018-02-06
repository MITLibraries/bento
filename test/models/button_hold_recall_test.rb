require 'test_helper'

class ButtonHoldRecallTest < ActiveSupport::TestCase
  setup do
    VCR.use_cassette('realtime aleph volume') do
      @item = AlephItem.new.xml_status('MIT01001019412').xpath('//items').children.first
    end
    @oclc = '123456789'
    @scan = 'true'
    @button = ButtonHoldRecall.new(@item, @oclc, @scan)
  end

  test 'html_button_recall' do
    @button.stub :eligible_recall?, true do
      assert(@button.html_button.include?('Recall (7+ days)'))
      refute(@button.html_button.include?('Place hold (1-2 days)'))
    end
  end

  test 'html_button_hold' do
    @button.stub :eligible_hold?, true do
      assert(@button.html_button.include?('Place hold (1-2 days)'))
      refute(@button.html_button.include?('Recall (7+ days)'))
    end
  end

  test 'html_button_ineligible' do
    @button.stub :eligible_hold?, false do
      assert_nil(@button.html_button)
    end
  end

  test 'status in library can hold not recall' do
    maker = ButtonHoldRecall.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@status, 'In Library')
    assert maker.eligible_hold?
    refute maker.eligible_recall?
  end

  test 'status MIT Reads can hold not recall' do
    maker = ButtonHoldRecall.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@status, 'MIT Reads')
    assert maker.eligible_hold?
    refute maker.eligible_recall?
  end

  test 'on reserve cannot hold or recall' do
    maker = ButtonHoldRecall.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@on_reserve, true)
    refute maker.eligible_hold?
    refute maker.eligible_recall?
  end

  test 'physics reading room cannot hold or recall' do
    maker = ButtonHoldRecall.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@library, 'Physics Dept. Reading Room')
    refute maker.eligible_hold?
    refute maker.eligible_recall?
  end

  test 'due sometime cannot hold can recall' do
    maker = ButtonHoldRecall.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@status, 'Due sometime')
    refute maker.eligible_hold?
    assert maker.eligible_recall?
  end

  test 'status missing cannot hold or recall' do
    maker = ButtonHoldRecall.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@status, 'Missing')
    refute maker.eligible_hold?
    refute maker.eligible_recall?
  end

  test 'hold ineligibility by reason of z30 status code' do
    maker = ButtonHoldRecall.new(@item, @oclc, @scan)

    # Check our assumption that the default ButtonMaker can be held/recalled.
    assert maker.eligible_hold?
    refute maker.eligible_recall?

    # Now test z30 status codes that should yield ineligibility.
    maker.instance_variable_set(:@z30status_code, '04')
    refute maker.eligible_hold?
    refute maker.eligible_recall?

    maker.instance_variable_set(:@z30status_code, '06')
    refute maker.eligible_hold?
    refute maker.eligible_recall?

    maker.instance_variable_set(:@z30status_code, '07')
    refute maker.eligible_hold?
    refute maker.eligible_recall?

    maker.instance_variable_set(:@z30status_code, '08')
    refute maker.eligible_hold?
    refute maker.eligible_recall?

    maker.instance_variable_set(:@z30status_code, '09')
    refute maker.eligible_hold?
    refute maker.eligible_recall?

    maker.instance_variable_set(:@z30status_code, '11')
    refute maker.eligible_hold?
    refute maker.eligible_recall?

    maker.instance_variable_set(:@z30status_code, '20')
    refute maker.eligible_hold?
    refute maker.eligible_recall?
  end

  test 'recall ineligibility by reason of z30 status code' do
    maker = ButtonHoldRecall.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@status, 'Due sometime')

    # Check our assumption that the default ButtonMaker can be held/recalled.
    refute maker.eligible_hold?
    assert maker.eligible_recall?

    # Now test z30 status codes that should yield ineligibility.
    maker.instance_variable_set(:@z30status_code, '04')
    refute maker.eligible_hold?
    refute maker.eligible_recall?

    maker.instance_variable_set(:@z30status_code, '06')
    refute maker.eligible_hold?
    refute maker.eligible_recall?

    maker.instance_variable_set(:@z30status_code, '07')
    refute maker.eligible_hold?
    refute maker.eligible_recall?

    maker.instance_variable_set(:@z30status_code, '08')
    refute maker.eligible_hold?
    refute maker.eligible_recall?

    maker.instance_variable_set(:@z30status_code, '09')
    refute maker.eligible_hold?
    refute maker.eligible_recall?

    maker.instance_variable_set(:@z30status_code, '11')
    refute maker.eligible_hold?
    refute maker.eligible_recall?

    maker.instance_variable_set(:@z30status_code, '20')
    refute maker.eligible_hold?
    refute maker.eligible_recall?
  end

  test 'url for hold' do
    url = @button.url
    parsed_url = URI.parse(URI.encode(url))
    assert_equal('library.mit.edu', parsed_url.host)
    assert_equal('/F', parsed_url.path)
    queryarray = { 'func' => 'item-hold-request',
                   'doc_library' => 'MIT50',
                   'adm_doc_number' => '001019412',
                   'item_sequence' => '000130' }
    assert_equal(queryarray, URI.decode_www_form(parsed_url.query).to_h)
  end
end
