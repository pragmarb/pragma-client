require 'webmock/rspec'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = File.join(
    File.expand_path('../..', __FILE__),
    'fixtures',
    'vcr_cassettes'
  )
  config.hook_into :webmock
end
