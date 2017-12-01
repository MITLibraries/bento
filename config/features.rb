Flipflop.configure do
  # Strategies will be used in the order listed here.
  strategy :session
  strategy :default

  feature :debug,
    default: false,
    description: 'Debug mode'

  feature :local_browse,
    default: false,
    description: 'Enables local browsing of paginated results'

  feature :check_online,
    default: false,
    description: 'Enables button for EDS supplied non-subscribed SFX links'

  feature :local_full_record,
    default: ENV['LOCAL_FULL_RECORD'],
    description: 'Enables local full record instead of sending to EDS UI'

  feature :hint_tracker,
    default: ENV['HINT_TRACKER'],
    description: 'Sends hint display to GA'

  feature :pride,
    default: ENV['PRIDE'],
    description: 'Enables rainbows for records with LGBT subjects/keywords'

  feature :full_record_toggle_button,
    default: ENV['FULL_RECORD_TOGGLE_BUTTON'],
    description: 'Enables a UI element to toggle full record. local_full_record,
                  still controls the actual full record display. This just
                  enables an affordance to toggle between states.'
end
