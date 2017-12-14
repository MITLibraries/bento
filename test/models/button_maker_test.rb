require 'test_helper'

class ButtonMakerTest < ActiveSupport::TestCase
  setup do
    VCR.use_cassette('realtime aleph volume') do
      @item = AlephItem.new.xml_status('MIT01001019412').xpath('//items').children.first
    end
    @oclc = '123456789'
    @scan = 'true'
    @ButtonMaker = ButtonMaker.new(@item, @oclc, @scan)
  end

  test 'all buttons' do
    assert @ButtonMaker.all_buttons.include? @ButtonMaker.make_button_for_hold
    assert @ButtonMaker.all_buttons.include? @ButtonMaker.make_button_for_scan

    refute @ButtonMaker.all_buttons.include? @ButtonMaker.make_button_for_contact
    refute @ButtonMaker.all_buttons.include? @ButtonMaker.make_button_for_ill
    refute @ButtonMaker.all_buttons.include? @ButtonMaker.make_button_for_recall
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Test item properties ~~~~~~~~~~~~~~~~~~~~~~~~~~
  test 'barcode' do
    assert_equal('39080023421933', @ButtonMaker.instance_variable_get(:@barcode))
  end

  test 'call number' do
    assert_equal('PS3515.U274 2001', @ButtonMaker.instance_variable_get(:@call_number))
  end

  test 'collection' do
    assert_equal('Stacks', @ButtonMaker.instance_variable_get(:@collection))
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~ Test item properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  test 'doc_number' do
    assert_equal('001019412', @ButtonMaker.instance_variable_get(:@doc_number))
  end

  test 'identifier' do
    assert_equal('0826213391', @ButtonMaker.instance_variable_get(:@identifier))
  end

  test 'item_sequence' do
    assert_equal('000130', @ButtonMaker.instance_variable_get(:@item_sequence))
  end

  test 'library' do
    assert_equal('Hayden Library', @ButtonMaker.instance_variable_get(:@library))
  end

  test 'oclc_number' do
    assert_equal('123456789', @ButtonMaker.instance_variable_get(:@oclc_number))
  end

  test 'oclc_number messy data' do
    messy_button = ButtonMaker.new(@item, '123456789&lt;br/&gt;947074821',
                                   @scan)
    assert_equal('123456789', messy_button.instance_variable_get(:@oclc_number))
  end

  test 'status' do
    assert_equal('In Library', @ButtonMaker.instance_variable_get(:@status))
  end

  test 'title' do
    assert_equal('The collected works of Langston Hughes / edited with an introduction by Arnold Rampersad.',
                  @ButtonMaker.instance_variable_get(:@title))
  end

  test 'z30status' do
    assert_equal('60 Day Loan', @ButtonMaker.instance_variable_get(:@z30status))
  end

  test 'z30status_code' do
    assert_equal('01', @ButtonMaker.instance_variable_get(:@z30status_code))
  end

  # ~~~~~~~~~~~~~~~~~ Test eligibility determination functions ~~~~~~~~~~~~~~~~~
  test 'eligible for scan' do
    # If any subcondition is false, it is ineligible.
    @ButtonMaker.stub :call_number_valid_for_scan?, false do
      refute @ButtonMaker.eligible_for_scan?
    end

    @ButtonMaker.stub :z30status_valid_for_scan?, false do
      refute @ButtonMaker.eligible_for_scan?
    end

    @ButtonMaker.stub :collection_valid_for_scan?, false do
      refute @ButtonMaker.eligible_for_scan?
    end

    @ButtonMaker.stub :status_valid_for_scan?, false do
      refute @ButtonMaker.eligible_for_scan?
    end

    @ButtonMaker.stub :library_valid_for_scan?, false do
      refute @ButtonMaker.eligible_for_scan?
    end

    @ButtonMaker.stub :unscannable_standard?, true do
      refute @ButtonMaker.eligible_for_scan?
    end
    # If all subconditions are true, it is eligible.
    @ButtonMaker.stub :call_number_valid_for_scan?, true do
      @ButtonMaker.stub :z30status_valid_for_scan?, true do
        @ButtonMaker.stub :collection_valid_for_scan?, true do
          @ButtonMaker.stub :status_valid_for_scan?, true do
            @ButtonMaker.stub :library_valid_for_scan?, true do
              @ButtonMaker.stub :unscannable_standard?, false do
                assert @ButtonMaker.eligible_for_scan?
              end
            end
          end
        end
      end
    end
  end

  test 'eligible for contact' do
    maker = ButtonMaker.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@library, 'Institute Archives')
    assert maker.eligible_for_contact?

    maker.instance_variable_set(:@library, 'Not the Archives')
    refute maker.eligible_for_contact?
  end

  test 'eligible for hold' do
    maker = ButtonMaker.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@status, 'In Library')
    maker.instance_variable_set(:@requestable, true)
    assert maker.eligible_for_hold?

    maker.instance_variable_set(:@status, 'MIT Reads')
    assert maker.eligible_for_hold?

    maker.instance_variable_set(:@requestable, false)
    refute maker.eligible_for_hold?

    maker.instance_variable_set(:@on_reserve, true)
    refute maker.eligible_for_hold?

    maker.instance_variable_set(:@on_reserve, false)
    maker.instance_variable_set(:@library, 'Physics Dept. Reading Room')
    refute maker.eligible_for_hold?
  end

  test 'eligible for ill' do
    maker = ButtonMaker.new(@item, @oclc, @scan)

    # Eligible for hold -> ineligible for ILL.
    maker.instance_variable_set(:@status, 'In Library')
    maker.instance_variable_set(:@requestable, true)
    refute maker.eligible_for_ill?

    maker.instance_variable_set(:@library, 'Hayden Library')
    maker.instance_variable_set(:@status, 'Received')
    refute maker.eligible_for_ill?

    maker.instance_variable_set(:@status, 'Not in library')
    maker.instance_variable_set(:@z30status, '1 Day Loan')
    refute maker.eligible_for_ill?
  end

  test 'eligible for recall' do
    maker = ButtonMaker.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@requestable, true)
    maker.instance_variable_set(:@status, 'Due sometime')
    assert maker.eligible_for_recall?

    maker.instance_variable_set(:@on_reserve, true)
    refute maker.eligible_for_recall?

    maker.instance_variable_set(:@on_reserve, false)
    maker.instance_variable_set(:@library, 'Physics Dept. Reading Room')
    refute maker.eligible_for_recall?
  end

  test 'eligible for recall edge case' do
    maker = ButtonMaker.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@requestable, true)
    maker.instance_variable_set(:@status, 'Missing')
    refute maker.eligible_for_recall?
  end

  test 'hold ineligibility by reason of z30 status code' do
    maker = ButtonMaker.new(@item, @oclc, @scan)

    # Check our assumption that the default ButtonMaker can be held/recalled.
    assert maker.eligible_for_hold?

    # Now test z30 status codes that should yield ineligibility.
    maker.instance_variable_set(:@z30status_code, '04')
    # We need to reset @requestable as it was set on object initialization, but
    # the change to the z30 status will alter its expected value.
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_hold?

    maker.instance_variable_set(:@z30status_code, '06')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_hold?

    maker.instance_variable_set(:@z30status_code, '07')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_hold?

    maker.instance_variable_set(:@z30status_code, '08')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_hold?

    maker.instance_variable_set(:@z30status_code, '09')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_hold?

    maker.instance_variable_set(:@z30status_code, '11')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_hold?

    maker.instance_variable_set(:@z30status_code, '20')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_hold?
  end

  test 'recall ineligibility by reason of z30 status code' do
    maker = ButtonMaker.new(@item, @oclc, @scan)
    maker.instance_variable_set(:@status, 'Due sometime')

    # Check our assumption that the default ButtonMaker can be held/recalled.
    assert maker.eligible_for_recall?

    # Now test z30 status codes that should yield ineligibility.
    maker.instance_variable_set(:@z30status_code, '04')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_recall?

    maker.instance_variable_set(:@z30status_code, '06')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_recall?

    maker.instance_variable_set(:@z30status_code, '07')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_recall?

    maker.instance_variable_set(:@z30status_code, '08')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_recall?

    maker.instance_variable_set(:@z30status_code, '09')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_recall?

    maker.instance_variable_set(:@z30status_code, '11')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_recall?

    maker.instance_variable_set(:@z30status_code, '20')
    maker.instance_variable_set(:@requestable, maker.requestable?)
    refute maker.eligible_for_recall?
  end

  # ~~~~~~~~~~~~~~~~~ Test URLs for availability action buttons ~~~~~~~~~~~~~~~~
  test 'pdf scan URL in test env' do
    @ButtonMaker.stub :eligible_for_scan?, true do
      url =  [
        'https://sfx.mit.edu/sfx_test',
        '?sid=ALEPH:BENTO',
        "&amp;call_number=PS3515.U274%202001",
        '&amp;barcode=39080023421933',
        '&amp;title=The%2520collected%2520works%2520of%2520Langston%2520Hughes%2520%252F%2520edited%2520with%2520an%2520introduction%2520by%2520Arnold%2520Rampersad.',
        '&amp;location=Hayden%2520Library',
        '&amp;genre=journal'
      ].join('')
      assert_equal(url, @ButtonMaker.url_for_scan)
    end
  end

  test 'pdf scan URL in production env' do
    Rails.stub :env, ActiveSupport::StringInquirer.new('production') do
      @ButtonMaker.stub :eligible_for_scan?, true do
        url =  [
          'https://sfx.mit.edu/sfx_local',
          '?sid=ALEPH:BENTO',
          "&amp;call_number=PS3515.U274%202001",
          '&amp;barcode=39080023421933',
          '&amp;title=The%2520collected%2520works%2520of%2520Langston%2520Hughes%2520%252F%2520edited%2520with%2520an%2520introduction%2520by%2520Arnold%2520Rampersad.',
          '&amp;location=Hayden%2520Library',
          '&amp;genre=journal'
        ].join('')
        assert_equal(url, @ButtonMaker.url_for_scan)
      end
    end
  end

  test 'url for hold' do
    url = @ButtonMaker.url_for_hold
    parsed_url = URI.parse(URI.encode(url))
    assert_equal('library.mit.edu', parsed_url.host)
    assert_equal('/F', parsed_url.path)
    queryarray = { 'func' => 'item-hold-request',
                   'doc_library' => 'MIT50',
                   'adm_doc_number' => '001019412',
                   'item_sequence' => '000130' }
    assert_equal(queryarray, URI.decode_www_form(parsed_url.query).to_h)
  end

  test 'url for ill' do
    assert_equal('https://mit.worldcat.org/search?q=no%3A123456789',
                 @ButtonMaker.url_for_ill)
  end
end
