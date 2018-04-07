require_relative 'db_connection'
require_relative 'searchable'
require 'active_support/inflector'

class SQLObject
  extend Searchable

  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{table_name}
      LIMIT
        1
    SQL
  end

  def self.finalize!
    columns.each do |col|
      define_method(col) { attributes[col] }
      define_method("#{col}=") { |val| attributes[col] = val}
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    parse_all(DBConnection.execute(<<-SQL))
      SELECT
        *
      FROM
        #{table_name}
    SQL
  end

  def self.parse_all(results)
    results.map { |row| self.new(row) }
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    result.empty? ? nil : self.new(result.first)
  end

  def initialize(params = {})
    params.each do |col, val|
      raise "unknown attribute '#{col}'" unless self.class.columns.include?(col.to_sym)
      send("#{col}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    col_names = self.class.columns.reject { |name| name == :id }
    vals = col_names.map { |name| send(name) }
    question_marks = (['?'] * vals.length).join(', ')
    col_names = col_names.join(', ')

    DBConnection.execute(<<-SQL, *vals)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_names = self.class.columns.reject { |name| name == :id }
    vals = col_names.map { |name| send(name) }
    col_names = col_names.map { |name| "#{name} = ?" }.join(', ')

    DBConnection.execute(<<-SQL, *vals, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        id = ?
    SQL
  end

  def save
    id ? update : insert
  end
end

TracePoint.new(:end) do |tp|
  klass = tp.binding.receiver
  klass.finalize! if klass.respond_to?(:finalize!)
end.enable
