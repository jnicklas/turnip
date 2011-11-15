require 'spec_helper'

describe Turnip::Builder::Step do
  describe '.variations' do
    context 'with a single keyword' do
      let(:keywords) {['Given ']}
      let(:description) {'a big hairy monster'}
  
      context 'with :flexible step_match_mode' do
        before {Turnip::Config.step_match_mode = :flexible}
        after {Turnip::Config.step_match_mode = :flexible}
    
        it 'should include both the exact and generic variants' do
          step = Turnip::Builder::Step.new(keywords, description, nil)
          step.variations.should include('a big hairy monster')
          step.variations.should include('Given a big hairy monster')
        end
      end
  
      context 'with :exact step_match_mode' do
        before {Turnip::Config.step_match_mode = :exact}
        after {Turnip::Config.step_match_mode = :flexible}
      
        it 'should include only the exact variant' do
          step = Turnip::Builder::Step.new(keywords, description, nil)
          step.variations.should_not include('a big hairy monster')
          step.variations.should include('Given a big hairy monster')
        end
      end
  
      context 'with :generic step_match_mode' do
        before {Turnip::Config.step_match_mode = :generic}
        after {Turnip::Config.step_match_mode = :flexible}
      
        it 'should include only the generic variant' do
          step = Turnip::Builder::Step.new(keywords, description, nil)
          step.variations.should include('a big hairy monster')
          step.variations.should_not include('Given a big hairy monster')
        end
      end
    end
    
    context 'with multiple keywords' do
      let(:keywords) {['Dado ', 'Dada ', 'Dados ', 'Dadas ']}
      let(:description) {'que hay 23 monstruos'}
      
      context 'with :flexible step_match_mode' do
        before {Turnip::Config.step_match_mode = :flexible}
        after {Turnip::Config.step_match_mode = :flexible}
    
        it 'should include all exact and generic variants' do
          step = Turnip::Builder::Step.new(keywords, description, nil)
          step.variations.should include('que hay 23 monstruos')
          step.variations.should include('Dado que hay 23 monstruos')
          step.variations.should include('Dada que hay 23 monstruos')
          step.variations.should include('Dados que hay 23 monstruos')
          step.variations.should include('Dadas que hay 23 monstruos')
        end
      end
  
      context 'with :exact step_match_mode' do
        before {Turnip::Config.step_match_mode = :exact}
        after {Turnip::Config.step_match_mode = :flexible}
      
        it 'should include only the exact variants' do
          step = Turnip::Builder::Step.new(keywords, description, nil)
          step.variations.should_not include('que hay 23 monstruos')
          step.variations.should include('Dado que hay 23 monstruos')
          step.variations.should include('Dada que hay 23 monstruos')
          step.variations.should include('Dados que hay 23 monstruos')
          step.variations.should include('Dadas que hay 23 monstruos')
        end
      end
  
      context 'with :generic step_match_mode' do
        before {Turnip::Config.step_match_mode = :generic}
        after {Turnip::Config.step_match_mode = :flexible}
      
        it 'should include only the generic variant' do
          step = Turnip::Builder::Step.new(keywords, description, nil)
          step.variations.should include('que hay 23 monstruos')
          step.variations.should_not include('Dado que hay 23 monstruos')
          step.variations.should_not include('Dada que hay 23 monstruos')
          step.variations.should_not include('Dados que hay 23 monstruos')
          step.variations.should_not include('Dadas que hay 23 monstruos')
        end
      end
    end
  end
end