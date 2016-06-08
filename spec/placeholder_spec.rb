require 'turnip/placeholder'

describe Turnip::Placeholder do
  describe '.resolve' do
    before do
      described_class.add(:test) do
        match(/foo/)
        match(/\d/)
      end
    end

    it 'returns a regexp for the given placeholder' do
      resolved = described_class.resolve(:test)

      expect('foo').to match(resolved)
      expect('bar').not_to match(resolved)
      expect('5').to match(resolved)
    end

    it 'fall through to using the standard placeholder regexp' do
      resolved = described_class.resolve(:does_not_exist)

      match_standard_regexp_strings = [
        [ %q(non_space_string),      'non_space_string'    ],
        [ %q('around single quote'), 'around single quote' ],
        [ %q("around double quote"), 'around double quote' ],
      ]

      match_standard_regexp_strings.each do |step, expect_str|
        actual_str = resolved.match(step).captures.find { |m| !m.nil? }
        expect(expect_str).to eq(actual_str)
      end

      mismatch_standard_regexp_strings = [
        [ %q(with space string),  'with space string' ],
        [ %q('single to double"), 'single to double'  ],
        [ %q("double to single'), 'double to single'  ],
        [ %q("double to none),    'double to none'  ],
        [ %q(none to single'),    'none to single'  ],
      ]

      mismatch_standard_regexp_strings.each do |step, expect_str|
        actual_str = resolved.match(step).captures.find { |m| !m.nil? }
        expect(expect_str).not_to eq(actual_str)
      end
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
        default { |value| value.gsub(' ', '').to_sym }
        match(/foo/) { :foo_bar }
        match(/\d/) { |num| num.to_i }

        # It will be ignored (does not override first `default`)
        default { |value| value.gsub(' ', '-').to_sym }
      end

      expect(placeholder.apply('foo')).to eq :foo_bar
      expect(placeholder.apply('bar')).to eq :bar
      expect(placeholder.apply('"fizz buzz"')).to eq :fizzbuzz
      expect(placeholder.apply("'fizz buzz'")).to eq :fizzbuzz
      expect(placeholder.apply('5')).to eq 5
    end

    it 'extracts any captured expressions and passes to the block' do
      placeholder = described_class.new(:test) do
        match(/mo(nk)(ey)/) { |nk, ey| nk.to_s.reverse + '|' + ey.to_s.upcase }
      end

      expect(placeholder.apply('monkey')).to eq('kn|EY')
      expect(placeholder.apply('bar')).to eq('bar')
    end

    it 'extracts captures by default placeholder and passes to the block' do
      placeholder = described_class.new(:test) do
        default do |v|
          v
        end
      end

      expect(placeholder.apply('John Doe')).to eq('John Doe')
      expect(placeholder.apply('"John Doe"')).to eq('John Doe')
      expect(placeholder.apply('\'John Doe\'')).to eq('John Doe')

      expect(placeholder.apply('John \n Doe')).to eq('John \n Doe')
      expect(placeholder.apply('"John \n Doe"')).to eq('John \n Doe')
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
