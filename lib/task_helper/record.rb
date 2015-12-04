module TaskHelper
  class Record < Base
    data_member :app_id, :entity_id, :approved, :values

    def self.find(id, database_id:)
      if response = get(route: "apps/#{database_id}/dtypes/#{id}.json")
        new response['record'] if response['record']
      end
    end

    def initialize(args = {}, form: nil, **params)
      @form = form
      super(args.merge(params))
    end

    def form
      @form ||= Form.find(database: app_id, form: entity_id)
    end

    def fields
      form.fields
    end

    def [](field_name)
      pretty_values[field_name]
    end

    def pretty_values
      @pretty_values ||= values.each_with_object({}) do |(k,v), r|
        field = fields.find { |f| f.id == k }
        r[field.name] = v
      end
    end
  end
end
