namespace :spec do
  task :setup, [:api_key] do |t, args|
    MTH::API.rest_api_key = args[:api_key]

    File.open('spec/support/fixtures/databases.json', 'w') do |f|
      f.write(JSON.pretty_generate(MTH::API.get(route: 'apps.json')))
    end

    MTH::API.get(route: 'apps.json')['databases'].each do |db|
      dir = "spec/support/fixtures/databases/#{db['id']}"
      route = "apps/#{db['id']}/entities.json"
      FileUtils.mkdir_p(dir)
      File.open("#{dir}/forms.json", 'w') do |f|
        f.write(JSON.pretty_generate(MTH::API.get(route: route)))
      end
    end
  end
end
