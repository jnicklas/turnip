module Turnip
  class Table
    attr_reader :raw
    alias_method :to_a, :raw

    include Enumerable

    def initialize(raw)
      @raw = raw
    end

    def headers
      @raw.first
    end

    def rows
      @raw.drop(1)
    end

    def hashes
      rows.map { |row| Hash[headers.zip(row)] }
    end
    
    def rows_hash
      return @rows_hash if @rows_hash
      verify_table_width(2)
      @rows_hash = self.class.new(raw.transpose).hashes[0]
    end

    def each
      @raw.each { |row| yield(row) }
    end
    
    private
    
    def verify_table_width(width)
      raise %{The table must have exactly #{width} columns} unless raw[0].size == width
    end
  end
end
