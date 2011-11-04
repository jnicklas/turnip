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

    def each
      @raw.each { |row| yield(row) }
    end
  end
end
