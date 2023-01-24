Flipflop.configure do
  # Strategies will be used in the order listed here.
  strategy :session
  strategy :default
  
  feature :primo_search,
    default: ActiveModel::Type::Boolean.new.cast(ENV.fetch('PRIMO_SEARCH')),
    description: 'Returns results from Primo Search API instead of EDS'

  feature :timdex_v2,
    default: ActiveModel::Type::Boolean.new.cast(ENV.fetch('TIMDEX_V2', false)),
    description: "Call TIMDEX V2 instead of V1"
end
