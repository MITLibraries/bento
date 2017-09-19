module Rainbows
  # Determines whether the rainbow header should be shown.
  # Context: when library director Chris Bourg was apprised of the existence
  # of the rainbows Easter egg, she thought it was great and could we show it
  # if people were looking at LGBT stuff. Why, yes. Yes we can.
  #
  # CITATIONS:
  #
  # This is partly inspired by the approach in
  # https://www.ideals.illinois.edu/handle/2142/97437 . It uses the
  # author's list of LGBT vocabulary as a starting point for checking
  # uncontrolled keywords. It removes a few terms that also commonly refer to
  # non-LGBT topics, and adds some inflected forms as they would otherwise be
  # missed by the set-intersection logic.
  #
  # It also uses http://www.netanelganin.com/projects/QueerLCSH/QueerLCSH.xml
  # (as of 13 September 2017) for LCSH, again removing terms that also commonly
  # refer to non-LGBT topics.
  #
  # GIANT CAVEATS:
  #
  # LCSH doesn't fit well with the language that actual LGBT
  # people use in searching for and describing LGBT topics, so this is an
  # extremely rough estimate. Also the thesis referenced above had a small
  # number of study participants who were not broadly representative of LGBT
  # identities. This code should be treated as a very rough draft with
  # substantial room for improvement. Pull requests welcome.

  QUEERLCSH = YAML.load_file(Rails.root.join('config', 'rainbows.yml'))

  def pride?
    vocabulary = ['bisexual', 'bisexuals', 'fag', 'fags', 'femme', 'femmes',
                  'gay', 'gays', 'gay men', 'gender identity',
                  'gender identities', 'homosexual', 'homosexuals', 'lesbian',
                  'lesbians', 'lgbt', 'lgbts', 'lgbtqia', 'multiple genders',
                  'queer', 'queers', 'queering', 'pansexual', 'transgender',
                  'transsexual', 'trans*', 'butch']

    kw = normalize_keywords
    subj = normalize_subjects

    (kw & vocabulary).present? || (subj & QUEERLCSH).present?
  end

  # If rainbows are already in the params, leave them alone. If not, check to
  # see if they should be inserted.
  def rainbowify?
    return if params.keys.include?('rainbows')
    params.merge!(rainbows: true) if pride?
  end

  def normalize_keywords
    return if @keywords.blank?
    # Note that we're not *changing* the instance variable here; we want to
    # normalize all our keywords to lowercase so we don't have false negatives
    # in comparing them against our vocabulary, but we want to display them to
    # end users with traditional capitalization.
    @keywords.map(&:downcase)
  end

  def normalize_subjects
    return if @subjects.blank?

    # We don't want to mutate the instance variable here, either.
    subj = @subjects.map(&:downcase)
    subj.map! { |x| x.gsub(/ & /, ' and ') }

    # This step throws out subdivisions (e.g. geographical ones) that would
    # otherwise be too numerous to handle, but unfortunately means we miss a
    # handful of LCSH terms that include dashes at the level we care about
    # (such as `libraries--services to bisexuals`; we don't want to just match
    # "libraries" here, even though libraries are also in a way :rainbow: .)
    subj.map! { |x| x.split('--')[0] }
    subj.map!(&:strip)
    subj
  end
end
