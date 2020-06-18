require 'test_helper'

class ButtonAeonTest < ActiveSupport::TestCase
  setup do
    VCR.use_cassette('realtime aleph volume') do
      @item = AlephItem.new.xml_status('MIT01001019412').xpath('//items').children.first
    end
    @oclc = '123456789'
    @scan = 'true'
    @button = ButtonAeon.new(@item, @oclc, @scan)
  end

  test 'html_button_eligible' do
    button = ButtonAeon.new(@item, @oclc, @scan)
    button.instance_variable_set(:@library, 'Institute Archives')
    assert(button.html_button.include?('Order a copy'))

    button.instance_variable_set(:@aeon_type, 'onsite')
    assert(button.html_button.include?('Request for on-site use'))
  end

  test 'html_button_ineligible' do
    assert_nil(@button.html_button)
  end

  test 'eligible for aeon' do
    maker = ButtonAeon.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@library, 'Institute Archives')
    assert maker.eligible?

    maker.instance_variable_set(:@library, 'Not the Archives')
    refute maker.eligible?

    maker.instance_variable_set(:@library, 'Rotch Library')
    refute maker.eligible?

    maker.instance_variable_set(:@library, 'Rotch Library')
    maker.instance_variable_set(:@collection, 'Limited Access Collection')
    assert maker.eligible?
  end
end
