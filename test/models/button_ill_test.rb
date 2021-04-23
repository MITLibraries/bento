require 'test_helper'

class ButtonIllTest < ActiveSupport::TestCase
  setup do
    VCR.use_cassette('realtime aleph volume') do
      @item = AlephItem.new.xml_status('MIT01001019412').xpath('//items').children.first
    end
    @oclc = '123456789'
    @scan = 'true'
    @button = ButtonIll.new(@item, @oclc, @scan)
  end

  test 'html_button_eligible' do
    @button.stubs(:eligible?).returns(true)
    assert(@button.html_button.include?('Request non-MIT copy (3-4 days)'))
  end

  test 'html_button_ineligible' do
    @button.stubs(:eligible?).returns(false)
    assert_nil(@button.html_button)
  end

  test 'eligible for ill' do
    maker = ButtonIll.new(@item, @oclc, @scan)

    # Eligible for hold -> ineligible for ILL.
    maker.instance_variable_set(:@status, 'In Library')
    maker.instance_variable_set(:@hold_recallable, true)
    refute maker.eligible?

    maker.instance_variable_set(:@library, 'Hayden Library')
    maker.instance_variable_set(:@status, 'Received')
    refute maker.eligible?

    maker.instance_variable_set(:@status, 'Not in library')
    maker.instance_variable_set(:@z30status, '1 Day Loan')
    refute maker.eligible?
  end

  test 'url for ill' do
    assert_equal(
      'https://mit.on.worldcat.org/oclc/123456789',
      @button.url
    )
  end

  test 'ill button returns nil if ill url cannot be constructed' do
    buttonmaker = ButtonIll.new(@item, '', @scan)
    # Check assumption: url should be nil by reason of the OCLC number being
    # blank.
    assert buttonmaker.url.nil?
    assert buttonmaker.html_button.nil?
  end
end
