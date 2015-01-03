module TaskHelper
  class Field < Base
    data_member :entity_id, :name, :desc, :type_name, :default,
                :validate_options, :position, :visible, :size, :cols,
                :rows, :initial, :pretty_type_name, :formula_field,
                :formula_operation, :start_from, :step

    def initialize(args = {}, form: nil, **params)
      @form = form
      super(args.merge(params))
    end

    def form
      @form ||=
        Database.all.each do |d|
          break Form.find(database: d.id, form: entity_id) || next
        end
    end
  end
end
