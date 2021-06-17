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

  feature :pride,
    default: ENV['PRIDE'],
    description: 'Enables rainbows for records with LGBT subjects/keywords'

  feature :disable_holds,
    default: ENV['DISABLE_HOLDS'],
    description: 'Determines if holds for local items are currently enabled'

  feature :disable_ills,
    default: ENV['DISABLE_ILLS'],
    description: 'Determines if ILLs for local items are currently enabled'

  feature :disable_recalls,
    default: ENV['DISABLE_RECALLS'],
    description: 'Determines if recalls for local items are currently enabled'

  feature :disable_scans,
    default: ENV['DISABLE_SCANS'],
    description: 'Determines if scans for local items are currently enabled'

  feature :disable_request_digital,
    default: ENV['DISABLE_REQUEST_DIGITAL'],
    description: 'Determines if request digital via SFX is currently enabled'

  feature :disable_worldcatinate,
    default: ENV['DISABLE_WORLDCATINATE'],
    description: 'Determines if links for renovation items should be enabled'

  feature :primo_search,
    default: ActiveModel::Type::Boolean.new.cast(ENV.fetch('PRIMO_SEARCH')),
    description: 'Returns results from Primo Search API instead of EDS'

  feature :primo_redirects,
    default: ActiveModel::Type::Boolean.new.cast(ENV.fetch('PRIMO_REDIRECTS')),
    description: 'Determines if Bento full record links should be redirected to Primo'
end
