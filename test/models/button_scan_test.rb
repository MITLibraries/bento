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

  test 'html_button_eligible' do
    assert(@button.html_button.include?('Request scan (2-3 days)'))
  end

  test 'html_button_ineligible' do
    @button.stub :eligible?, false do
      assert_nil(@button.html_button)
    end
  end

  # ~~~~~~~~~~~~~~~~~ Test eligibility determination functions ~~~~~~~~~~~~~~~~~
  test 'eligible for scan' do
    # If any subcondition is false, it is ineligible.
    @button.stub :call_number_valid?, false do
      refute @button.eligible?
    end

    @button.stub :z30status_valid?, false do
      refute @button.eligible?
    end

    @button.stub :collection_valid?, false do
      refute @button.eligible?
    end

    @button.stub :status_valid?, false do
      refute @button.eligible?
    end

    @button.stub :library_valid?, false do
      refute @button.eligible?
    end

    @button.stub :unscannable_standard?, true do
      refute @button.eligible?
    end
    # If all subconditions are true, it is eligible.
    @button.stub :call_number_valid?, true do
      @button.stub :z30status_valid?, true do
        @button.stub :collection_valid?, true do
          @button.stub :status_valid?, true do
            @button.stub :library_valid?, true do
              @button.stub :unscannable_standard?, false do
                assert @button.eligible?
              end
            end
          end
        end
      end
    end
  end

  # ~~~~~~~~~~~~~~~~~ Test URLs for availability action buttons ~~~~~~~~~~~~~~~~
  test 'pdf scan URL in test env' do
    @button.stub :eligible?, true do
      url =  [
        'https://sfx.mit.edu/sfx_test',
        '?sid=ALEPH:BENTO',
        "&amp;call_number=PS3515.U274+2001",
        '&amp;barcode=39080023421933',
        '&amp;title=The+collected+works+of+Langston+Hughes+%2F+edited+with+an+introduction+by+Arnold+Rampersad.',
        '&amp;location=Hayden+Library',
        '&amp;rft.date=2001&amp;rft.volume=v.16&amp;genre=journal'
      ].join('')
      assert_equal(url, @button.url)
    end
  end

  test 'pdf scan URL in production env' do
    Rails.stub :env, ActiveSupport::StringInquirer.new('production') do
      @button.stub :eligible?, true do
        url =  [
          'https://sfx.mit.edu/sfx_local',
          '?sid=ALEPH:BENTO',
          "&amp;call_number=PS3515.U274+2001",
          '&amp;barcode=39080023421933',
          '&amp;title=The+collected+works+of+Langston+Hughes+%2F+edited+with+an+introduction+by+Arnold+Rampersad.',
          '&amp;location=Hayden+Library',
          '&amp;rft.date=2001&amp;rft.volume=v.16&amp;genre=journal'
        ].join('')
        assert_equal(url, @button.url)
      end
    end
  end
end
