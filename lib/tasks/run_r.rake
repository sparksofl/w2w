task run_r: :environment do
  puts 'running ... '
  filepath = Rails.root.join('lib', 'external_scripts', 'script.r')
  output = `Rscript --vanilla #{filepath}`
  puts 'done'
end