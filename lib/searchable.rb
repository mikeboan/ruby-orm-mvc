require_relative 'db_connection'

module Searchable
  def where(params)
    whereline = params.keys.map { |col| "#{col} = ?" }.join(' AND ')

    parse_all(DBConnection.execute(<<-SQL, *params.values))
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{whereline}
    SQL
  end
end
