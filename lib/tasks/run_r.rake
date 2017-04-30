task run_r: :environment do
  puts 'runing ... '
  filepath = Rails.root.join('lib', 'external_scripts', 'script.R')
  output = `Rscript --vanilla #{filepath}`
  puts output
  puts 'done'
end