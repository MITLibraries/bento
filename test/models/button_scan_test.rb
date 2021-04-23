require 'test_helper'

class ButtonScanTest < ActiveSupport::TestCase
  setup do
    VCR.use_cassette('realtime aleph volume') do
      @item = AlephItem.new.xml_status('MIT01001019412').xpath('//items').children.first
    end
    @oclc = '123456789'
    @scan = 'true'
    @button = ButtonScan.new(@item, @oclc, @scan)
  end

  def mock_all_eligible
    @button.stubs(:call_number_valid?).returns(true)
    @button.stubs(:z30status_valid?).returns(true)
    @button.stubs(:collection_valid?).returns(true)
    @button.stubs(:status_valid?).returns(true)
    @button.stubs(:library_valid?).returns(true)
    @button.stubs(:unscannable_standard?).returns(false)
  end

  test 'html_button_eligible' do
    assert(@button.html_button.include?('Request scan (2-3 days)'))
  end

  test 'html_button_ineligible' do    
    @button.stubs(:eligible?).returns(false)
    assert_nil(@button.html_button)
  end

  # ~~~~~~~~~~~~~~~~~ Test eligibility determination functions ~~~~~~~~~~~~~~~~~
  test 'ineligible call number for scan' do
    mock_all_eligible

    @button.stubs(:call_number_valid?).returns(false)
    refute @button.eligible?
  end

  test 'ineligible z30status_valid for scan' do
    mock_all_eligible

    @button.stubs(:z30status_valid?).returns(false)
    refute @button.eligible?
  end

  test 'ineligible collection_valid for scan' do
    mock_all_eligible

    @button.stubs(:collection_valid?).returns(false)
    refute @button.eligible?
  end

  test 'ineligible status_valid for scan' do
    mock_all_eligible

    @button.stubs(:status_valid?).returns(false)
    refute @button.eligible?
  end

  test 'ineligible library_valid for scan' do
    mock_all_eligible
    
    @button.stubs(:library_valid?).returns(false)
    refute @button.eligible?
  end

  # This one is checking a negative rather than a positive so it's an inverse
  # of many of the other checks in this suite.
  test 'ineligible unscannable_standard for scan' do
    mock_all_eligible
    
    @button.stubs(:unscannable_standard?).returns(true)
    refute @button.eligible?
  end

  test 'all subconditions to eligible' do
    # this test doesn't realy do anything as by default our @button results in
    # the same thing as all this stubbing...
    mock_all_eligible

    assert @button.eligible?
  end

  # ~~~~~~~~~~~~~~~~~ Test URLs for availability action buttons ~~~~~~~~~~~~~~~~
  test 'pdf scan URL' do
    url =  [
      'https://sfx.mit.edu/sfx_test',
      '?sid=ALEPH:BENTO',
      "&amp;call_number=PS3515.U274+2001",
      '&amp;barcode=39080023421933',
      '&amp;title=The+collected+works+of+Langston+Hughes+%2F+edited+with+an+introduction+by+Arnold+Rampersad.',
      '&amp;location=Hayden+Library',
      '&amp;rft.date=2001&amp;rft.volume=v.16&amp;rft.stitle=&amp;genre=journal'
    ].join('')
    assert_equal(url, @button.url)
  end
end
