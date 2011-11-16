steps_for :adicion do
  class Calculador
    def push(n)
      @args ||= []
      @args << n
    end

    def add
      @args.inject(0){|n,sum| sum+=n}
    end

    def divide
      @args[0].to_f / @args[1].to_f
    end
  end
  
  attr_accessor :calculator
  
  step 'Dado que hay un calculadora' do
    self.calculator = Calculador.new
  end
  
  step 'Dado que he introducido :numero en la calculadora' do |numero|
    calculator.push numero.to_i
  end

  step 'Cuando oprimo el :op' do |op|
    @result = calculator.send op
  end

  step 'Entonces el resultado debe ser :result en la pantalla' do |result|
    @result.should == result.to_f
  end
end