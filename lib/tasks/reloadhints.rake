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

  desc 'Drop and reload hints from CSV file'
  task :custom, [:url] => :environment do |_task, args|
    Rails.logger.info('Reloading custom CSV hints')
    Rails.logger.info(
      "Pre-load custom CSV Hint Count: #{Hint.where(source: 'custom').count}"
    )
    Rails.logger.info("Hint source URL: #{args.url}")

    CustomHint.new(args.url).reload

    Rails.logger.info(
      "Post-load custom CSV Hint Count: #{Hint.where(source: 'custom').count}"
    )
  end
end
