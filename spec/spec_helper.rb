require 'active_record'
require 'dropbox'
require 'mechanize'

require 'dropbox_folder'

Dir[File.expand_path('../support/*.rb', __FILE__)].each do |f|
  require f
end

RSpec.configure do |config|
  config.before(:suite) do
    puts '=' * 80
    puts "Running specs against ActiveRecord #{ActiveRecord::VERSION::STRING}..."
    puts "Running specs"
    puts '=' * 80
    Schema.create
  end
end
