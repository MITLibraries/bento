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

  feature :hints,
    default: true,
    description: 'Enables best bet search hint placards'

  feature :local_full_record,
    default: ENV['LOCAL_FULL_RECORD'],
    description: 'Enables local full record instead of sending to EDS UI'

  feature :hint_tracker,
    default: ENV['HINT_TRACKER'],
    description: 'Sends hint display to GA'
end
