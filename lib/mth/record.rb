module MTH
  class Record < Base
    data_member :app_id, :entity_id, :approved, :values

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
