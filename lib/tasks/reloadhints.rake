namespace :reloadhints do
  desc 'Drop and Reload Hints from Aleph Source'
  task aleph: :environment do
    Rails.logger.info('Reloading Aleph Hints')
    Rails.logger.info(
      "Pre-load Aleph Hint Count: #{Hint.where(source: 'aleph').count}"
    )

    AlephHint.new.reload

    Rails.logger.info(
      "Post-load Aleph Hint Count: #{Hint.where(source: 'aleph').count}"
    )
  end
end
