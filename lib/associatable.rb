require 'active_support/inflector'
require 'byebug'
class AssocOptions
  attr_accessor :class_name, :foreign_key, :primary_key

  def model_class
    class_name.to_s.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
    @foreign_key = options[:foreign_key] ||
      "#{self_class_name.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      foreign_key = self.send(options.foreign_key)

      options.model_class.where(options.primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    if options.keys.include?(:through)
      has_many_through(name, options[:through], options[:source])
    else
      self.assoc_options[name] = HasManyOptions.new(name, self.to_s, options)

      define_method(name) do
        options = self.class.assoc_options[name]
        primary_key = self.send(options.primary_key)

        options.model_class.where(options.foreign_key => primary_key)
      end
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      results = DBConnection.execute(<<-SQL, self.send(through_options.foreign_key))
        SELECT
          #{source_options.table_name}.*
        FROM
          #{source_options.table_name}
        JOIN
          #{through_options.table_name}
        ON
          #{source_options.table_name}.#{source_options.primary_key} =
            #{through_options.table_name}.#{source_options.foreign_key}
        WHERE
          #{through_options.table_name}.#{through_options.primary_key} = ?
      SQL

      results.empty? ? nil : source_options.model_class.new(results.first)
    end
  end

  def has_many_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]

      if source_name
        source_options = through_options.model_class.assoc_options[source_name]
      else
        singular_name = name.to_s.singularize.to_sym

        source_options = through_options.model_class.assoc_options[name] ||
          through_options.model_class.assoc_options[singular_name]
      end

      if (through_options.is_a?(HasManyOptions) && source_options.is_a?(HasManyOptions))
        fk_table    = source_options.table_name
        pk_table    = through_options.table_name
        where_table = through_options.table_name
      elsif (through_options.is_a?(HasManyOptions) && source_options.is_a?(BelongsToOptions))
        fk_table    = through_options.table_name
        pk_table    = source_options.table_name
        where_table = through_options.table_name
      elsif (through_options.is_a?(BelongsToOptions) && source_options.is_a?(HasManyOptions))
        fk_table    = source_options.table_name
        pk_table    = through_options.table_name
        where_table = source_options.table_name
      end

      results = DBConnection.execute(<<-SQL, self.send(through_options.primary_key))
        SELECT
          #{source_options.table_name}.*
        FROM
          #{source_options.table_name}
        JOIN
          #{through_options.table_name}
        ON
          #{fk_table}.#{source_options.foreign_key} =
            #{pk_table}.#{through_options.primary_key}
        WHERE
          #{where_table}.#{through_options.foreign_key} = ?
      SQL

      results.empty? ? nil : source_options.model_class.parse_all(results)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end
