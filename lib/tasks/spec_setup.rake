namespace :spec do
  task :setup, [:api_key] do |t, args|
    MTH::API.rest_api_key = args[:api_key]

    File.open('spec/support/fixtures/databases.json', 'w') do |f|
      f.write(JSON.pretty_generate(MTH::API.get(route: 'apps.json')))
    end
  end
end
