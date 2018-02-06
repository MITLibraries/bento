require 'test_helper'

class ButtonContactTest < ActiveSupport::TestCase
  setup do
    VCR.use_cassette('realtime aleph volume') do
      @item = AlephItem.new.xml_status('MIT01001019412').xpath('//items').children.first
    end
    @oclc = '123456789'
    @scan = 'true'
    @button = ButtonContact.new(@item, @oclc, @scan)
  end

  test 'html_button_eligible' do
    button = ButtonContact.new(@item, @oclc, @scan)
    button.instance_variable_set(:@library, 'Institute Archives')
    assert(button.html_button.include?('Contact Us'))
  end

  test 'html_button_ineligible' do
    assert_nil(@button.html_button)
  end

  test 'eligible for contact' do
    maker = ButtonContact.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@library, 'Institute Archives')
    assert maker.eligible?

    maker.instance_variable_set(:@library, 'Not the Archives')
    refute maker.eligible?
  end
end
