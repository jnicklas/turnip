require 'turnip/placeholder'

describe Turnip::Placeholder do
  def anchor(exp)
    Regexp.new("^#{exp}$")
  end

  describe ".resolve" do
    it "returns a regexp for the given placeholder" do
      placeholder = Turnip::Placeholder.add(:test) { match(/foo/); match(/\d/) }
      resolved = Turnip::Placeholder.resolve(:test)
      "foo".should =~ anchor(resolved)
      "5".should =~ anchor(resolved)
      "bar".should_not =~ anchor(resolved)
    end

    it "fall through to using the standard placeholder regexp" do
      resolved = Turnip::Placeholder.resolve(:does_not_exist)
      "foo".should =~ anchor(resolved)
      '"this is a test"'.should =~ anchor(resolved)
      "foo bar".should_not =~ anchor(resolved)
    end
  end

  describe '.apply' do
    it 'recognize multiple placeholders and return block value' do
      described_class.add :test1 do
        match(/foo/) { :foo_bar }
        match(/\d/) { |num| num.to_i }
      end

      described_class.add :test2 do
        match(/bar/) { :bar_foo }
        match(/\d/) { |num| num.to_i * 2 }
      end

      expect(described_class.apply(:test1, 'foo')).to eq(:foo_bar)
      expect(described_class.apply(:test1, 'bar')).to eq('bar')
      expect(described_class.apply(:test1, '5')).to eq(5)

      expect(described_class.apply(:test2, 'foo')).to eq('foo')
      expect(described_class.apply(:test2, 'bar')).to eq(:bar_foo)
      expect(described_class.apply(:test2, '5')).to eq(10)
    end
  end

  describe '#apply' do
    it 'extracts a captured expression and passes to the block' do
      placeholder = described_class.new(:test) do
        match(/foo/) { :foo_bar }
        match(/\d/) { |num| num.to_i }
      end

      expect(placeholder.apply('foo')).to eq :foo_bar
      expect(placeholder.apply('bar')).to eq 'bar'
      expect(placeholder.apply('5')).to eq 5
    end

    it 'extracts any captured expressions and passes to the block' do
      placeholder = described_class.new(:test) do
        match(/mo(nk)(ey)/) { |nk, ey| nk.to_s.reverse + '|' + ey.to_s.upcase }
      end

      expect(placeholder.apply('monkey')).to eq('kn|EY')
      expect(placeholder.apply('bar')).to eq('bar')
    end
  end

  describe '#regexp' do
    context 'placeholder has a matcher' do
      let :placeholder do
        described_class.new(:test) do
          match(/foo/)
        end
      end

      it 'should match a given fragment' do
        expect('foo').to match(placeholder.regexp)
        expect('the fool').to match(placeholder.regexp)
      end

      it 'should not match an incorrect fragment' do
        expect('bar').not_to match(placeholder.regexp)
      end
    end

    context 'placeholder has multiple matchers' do
      let :placeholder do
        described_class.new(:test) do
          match(/foo/)
          match(/\d/)
        end
      end

      it 'should match multiple fragments' do
        expect('foo').to match(placeholder.regexp)
        expect('5').to match(placeholder.regexp)

        expect('the fool').to match(placeholder.regexp)
        expect('12345678').to match(placeholder.regexp)
      end

      it 'should not multiple incorrect fragments' do
        expect('bar').not_to match(placeholder.regexp)
      end
    end
  end
end
