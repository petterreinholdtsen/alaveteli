# Perform an SQL 'COUNT' against multiple tables in one database connection
#
# Examples
#
#    counter = RecordCounter.new(Holiday, :users).run
#    counter.holidays
#    # => 21
#    counter.users
#    # => 7
class RecordCounter

  attr_reader :tables

  # Public: Initialize a new RecordCounter
  #
  # *args - Array of ActiveRecord::Base subclasses or symbol table names.
  #         Can be a mix of Constants or :symbols.
  #
  # Examples
  #
  #    # Constants
  #    RecordCounter.new(PublicBody, Holiday)
  #
  #    # Symbol table names
  #    RecordCounter.new(:public_bodies, :holidays)
  #
  #    # Mix of Constants and symbol table names
  #    RecordCounter.new(PublicBody, :holidays)
  #
  # Returns a RecordCounter
  def initialize(*args)
    @tables = args.map do |arg|
      arg.respond_to?(:table_name) ? arg.table_name : arg.to_s
    end

    @tables.each do |table|
      (class << self; self; end).send(:attr_reader, table.to_sym)
    end
  end

  # Public: Execute the count agains all tables
  #
  # Returns a RecordCounter
  def run
    counts = execute_query
    tables.each do |table|
      value = counts.fetch(table, nil)
      count = try_convert_to_integer(value)
      instance_variable_set("@#{ table }", count)
    end
    self
  end

  private

  def execute_query
    ActiveRecord::Base.connection.select_one(counter_sql)
  end

  def counter_sql
    query = <<-SQL.strip_heredoc
    SELECT
      #{ tables.map { |table| table_count_sql(table) }.join(",\n  ") }
    ;
    SQL
  end

  def table_count_sql(table)
    "(SELECT COUNT(*) from #{ table }) as #{ table }"
  end

  def try_convert_to_integer(value)
    value.respond_to?(:to_i) ? value.to_i : value
  end

end
