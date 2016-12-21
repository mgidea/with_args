class WithArgs
  attr_reader :calling_method, :arguments
  attr_writer :collection
  def initialize(calling_method, *arguments)
    @calling_method = calling_method
    @arguments = arguments
  end

  def to_proc
    Proc.new {|object|
      object.send(calling_method, *get_arguments(object))
    }
  end

  def get_arguments(object)
    arguments.map do |argument|
      if (argument.is_a?(String) || argument.is_a?(Symbol)) && argument.to_s.match(/^\&/)
        meth = argument.to_s[1..-1]
        argument = object.send(meth) if object.respond_to?(meth)
      end
      argument
    end
  end

  def call(method, collection)
    collection.send(method, &self)
  end

  def self.call(collection, collection_method, calling_method, arguments)
    new(calling_method, *arguments).call(collection_method, collection)
  end
end

module ToProcWithArgs
  def with_args(calling_method, *args)
    WithArgs.new(calling_method, *args)
  end
end

class Array
  include ToProcWithArgs
  def to_proc
    with_args(shift, *self).to_proc
  end
end


#ActiveRecord::Base.send(:include, ToProcWithArgs)
