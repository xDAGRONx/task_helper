namespace :spec do
  task :setup, [:api_key] do |t, args|
    MTH::API.rest_api_key = args[:api_key]

    File.open('spec/support/fixtures/databases.json', 'w') do |f|
      f.write(JSON.pretty_generate(MTH::API.get(route: 'apps.json')))
    end

    MTH::API.get(route: 'apps.json')['databases'].each do |db|
      db_dir = "spec/support/fixtures/databases/#{db['id']}"
      db_route = "apps/#{db['id']}"
      forms_route = "#{db_route}/entities"
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

        if MTH::API.get(route: "#{fields_route}.json")['fields'].any?
          records_route = "#{db_route}/dtypes/entity/#{form['id']}"
          records_dir = "#{form_dir}/records"
          FileUtils.mkdir_p(records_dir)
          page_count = db['dtypes_count'].to_i / form['per_page'].to_i + 1
          (1..page_count).each do |page|
            File.open("#{records_dir}/#{page}.json", 'w') do |f|
              f.write(JSON.pretty_generate(MTH::API
                .get(route: "#{records_route}.json", params: { page: page })))
            end
          end
        end
      end
    end
  end
end
