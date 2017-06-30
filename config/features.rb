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
    default: false,
    description: 'Enables best bet search hint placards'
end
