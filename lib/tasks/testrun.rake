task testrun: :environment do
  puts 'running ... '
  filepath = Rails.root.join('lib', 'external_scripts', 'test.r')
  output = `Rscript --vanilla #{filepath}`
  puts 'done'
end