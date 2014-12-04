module TaskHelper
  class Base
    class << self
      attr_accessor :data_members
      protected :data_members=
    end

    def initialize(args = {})
      @info = {}
      (args || {}).each_pair do |k, v|
        @info[k.to_sym] = v
      end
    end

    def to_h
      @info.dup
    end

    def id
      fetch(:id)
    end

    def created_at
      Time.parse(fetch(:created_at)) if fetch(:created_at)
    end

    def updated_at
      Time.parse(fetch(:updated_at)) if fetch(:updated_at)
    end

    def ==(other)
      id == other.id
    end

    protected

    def fetch(attribute)
      @info[attribute.to_sym]
    end

    private

    def self.inherited(base)
      base.extend(API)
      base.data_members = %i(id)
    end

    def self.data_member(*names)
      names.each do |name|
        define_method(name) { fetch(name.to_sym) }
        data_members << name.to_sym
      end
    end
  end
end
