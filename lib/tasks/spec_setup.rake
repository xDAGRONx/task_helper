namespace :spec do
  task :setup, [:api_key] do |t, args|
    MTH::API.rest_api_key = args[:api_key]

    File.open('spec/support/fixtures/databases.json', 'w') do |f|
      f.write(JSON.pretty_generate(MTH::API.get(route: 'apps.json')))
    end

    MTH::API.get(route: 'apps.json')['databases'].each do |db|
      db_dir = "spec/support/fixtures/databases/#{db['id']}"
      forms_route = "apps/#{db['id']}/entities"
      FileUtils.mkdir_p(db_dir)
      File.open("#{db_dir}/forms.json", 'w') do |f|
        f.write(JSON.pretty_generate(MTH::API.get(route: "#{forms_route}.json")))
      end

      MTH::API.get(route: "apps/#{db['id']}/entities.json")['forms'].each do |form|
        form_dir = "#{db_dir}/forms/#{form['id']}"
        fields_route = "#{forms_route}/#{form['id']}/properties"
        FileUtils.mkdir_p(form_dir)
        File.open("#{form_dir}/fields.json", 'w') do |f|
          f.write(JSON.pretty_generate(MTH::API.get(route: "#{fields_route}.json")))
        end
      end
    end
  end
end
