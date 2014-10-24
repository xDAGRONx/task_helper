module MTH
  class Database < Base
    data_member :name, :dtypes_count, :entities_count, :properties_count

    def self.all
      get(route: 'apps.json')['databases'].map { |d| new d }
    end

    def self.find_by_name(name)
      find_by(name: name)
    end

    def self.find_by(search)
      if response = get(route: 'apps/search.json', params: search)
        new response['database'] if response['database']
      end
    end

    def self.find(id)
      if response = get(route: "apps/#{id}.json")
        new response['database'] if response['database']
      end
    end

    def forms
      @forms ||= Form.get(route: "apps/#{id}/entities.json")['forms']
        .map { |form| Form.new(form) }
    end
  end
end
