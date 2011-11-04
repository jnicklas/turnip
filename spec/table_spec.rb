require 'spec_helper'

describe Turnip::Table do
  describe '#raw' do
    it 'returns the raw table' do
      table = Turnip::Table.new([['foo', 'bar'], ['quox', '42']])
      table.raw.should == [['foo', 'bar'], ['quox', '42']]
    end
  end

  describe '#to_a' do
    it 'returns the raw table' do
      table = Turnip::Table.new([['foo', 'bar'], ['quox', '42']])
      table.to_a.should == [['foo', 'bar'], ['quox', '42']]
    end
  end

  describe '#headers' do
    it 'returns the first row' do
      table = Turnip::Table.new([['foo', 'bar'], ['quox', '42']])
      table.headers.should == ['foo', 'bar']
    end
  end

  describe '#rows' do
    it 'returns the rows beyond the first' do
      table = Turnip::Table.new([['foo', 'bar'], ['moo', '55'], ['quox', '42']])
      table.rows.should == [['moo', '55'], ['quox', '42']]
    end
  end

  describe '#hashes' do
    it 'returns a list of hashe based on the headers' do
      table = Turnip::Table.new([['foo', 'bar'], ['moo', '55'], ['quox', '42']])
      table.hashes.should == [
        {'foo' => 'moo', 'bar' => '55'},
        {'foo' => 'quox', 'bar' => '42'}
      ]
    end
  end

  describe '#map' do
    it 'iterates over the raw table' do
      table = Turnip::Table.new([['moo', '55'], ['quox', '42']])
      table.map(&:first).should == ['moo', 'quox']
    end
  end
end
