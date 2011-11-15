require 'spec_helper'

class EnglishLanguageStub
  attr_accessor :given, :when, :then, :and, :but
  
  def given
    @given ||= ["* ", "Given "]
  end
  
  def when
    @when ||= ["* ", "When "]
  end
  
  def then
    @then ||= ["* ", "Then "]
  end
  
  def and
    @and ||= ["* ", "And "]
  end
  
  def but
    @but ||= ["* ", "But "]
  end
  
  def keywords(key)
    send(key)
  end
end
class SpanishLanguageStub
  attr_accessor :given, :when, :then, :and, :but
  
  def given
    @given ||= ["* ", "Dado ", "Dada ", "Dados ", "Dadas "]
  end
  
  def when
    @when ||= ["* ", "Cuando "]
  end
  
  def then
    @then ||= ["* ", "Entonces "]
  end
  
  def and
    @and ||= ["* ", "Y "]
  end
  
  def but
    @but ||= ["* ", "Pero "]
  end
  
  def keywords(key)
    send(key)
  end
end

describe Turnip::StepKeywordFinder do
  describe '.step_keywords' do
    context 'for english language' do
      let(:i18n_language) {EnglishLanguageStub.new}
      let(:keyword_finder) {Turnip::StepKeywordFinder.new(i18n_language)}
  
      context 'for primary keywords' do
        it 'should return the appropriate keyword for "given"' do
          keyword_finder.step_keywords('Given ').should eq(['Given '])
        end
    
        it 'should return the appropriate keyword for "when"' do
          keyword_finder.step_keywords('When ').should eq(['When '])
        end
    
        it 'should return the appropriate keyword for "then"' do
          keyword_finder.step_keywords('Then ').should eq(['Then '])
        end
      end
    
      context 'for secondary keywords' do
        describe 'with no previous steps' do
          it 'should return the appropriate keyword for "and"' do
            keyword_finder.step_keywords('And ').should eq(['And '])
          end
        
          it 'should return the appropriate keyword for "but"' do
            keyword_finder.step_keywords('But ').should eq(['But '])
          end
        end
      
        describe 'with previous steps' do
          it 'should return the previous step keywords in addition to "and"' do
            keyword_finder.step_keywords('And ', [['Given '], ['And ']]).should eq(['And ', 'Given '])
          end
        
          it 'should return the previous step keywords in addition to "but"' do
            keyword_finder.step_keywords('But ', [['Then '], ['And ']]).should eq(['But ', 'Then '])
          end
        end
      end
    end
  
    context 'for spanish language' do
      let(:i18n_language) {SpanishLanguageStub.new}
      let(:keyword_finder) {Turnip::StepKeywordFinder.new(i18n_language)}
    
      context 'for primary keywords' do
        it 'should return the appropriate keyword for "dado"' do
          keyword_finder.step_keywords('Dado ').should eq(["Dado ", "Dada ", "Dados ", "Dadas "])
        end
      
        it 'should return the appropriate keyword for "cuando"' do
          keyword_finder.step_keywords('Cuando ').should eq(['Cuando '])
        end
      
        it 'should return the appropriate keyword for "then"' do
          keyword_finder.step_keywords('Entonces ').should eq(['Entonces '])
        end
      end
      
      context 'for secondary keywords' do
        describe 'with no previous steps' do
          it 'should return the appropriate keyword for "y"' do
            keyword_finder.step_keywords('Y ').should eq(['Y '])
          end
          
          it 'should return the appropriate keyword for "pero"' do
            keyword_finder.step_keywords('Pero ').should eq(['Pero '])
          end
        end
        
        describe 'with previous steps' do
          it 'should return the previous step keywords in addition to "y"' do
            keyword_finder.step_keywords('Y ', [["Dado ", "Dada ", "Dados ", "Dadas "], ['Y ']]).should eq(['Y ', "Dado ", "Dada ", "Dados ", "Dadas "])
          end
          
          it 'should return the previous step keywords in addition to "pero"' do
            keyword_finder.step_keywords('Pero ', [["Entonces "], ['Pero ']]).should eq(['Pero ', "Entonces "])
          end
        end
      end
    end
  end
end