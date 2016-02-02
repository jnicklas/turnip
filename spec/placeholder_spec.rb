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

  describe ".apply" do
    it "returns a regexp for the given placeholder" do
      placeholder = Turnip::Placeholder.add(:test) do
        match(/foo/) { :foo_bar }
        match(/\d/) { |num| num.to_i }
      end
      Turnip::Placeholder.apply(:test, "foo").should eq(:foo_bar)
      Turnip::Placeholder.apply(:test, "5").should eq(5)
      Turnip::Placeholder.apply(:test, "bar").should eq("bar")
    end

    it "extracts any captured expressions and passes them to the block" do
      placeholder = Turnip::Placeholder.add(:test) do
        match(/mo(nk)(ey)/) { |nk, ey| nk.to_s.reverse + '|' + ey.to_s.upcase }
      end
      Turnip::Placeholder.apply(:test, "monkey").should eq('kn|EY')
      Turnip::Placeholder.apply(:test, "bar").should eq("bar")
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
      end

      it 'should not multiple incorrect fragments' do
        expect('bar').not_to match(placeholder.regexp)
      end
    end
  end
end
