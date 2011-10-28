module Turnip
  def self.run(content)
    Turnip::Builder.build(content).features.each do |feature|
      describe feature.name, feature.metadata_hash do
        feature.backgrounds.each do |background|
          before do
            background.steps.each do |step|
              Turnip::StepDefinition.execute(self, step.name)
            end
          end
        end
        feature.scenarios.each do |scenario|
          it scenario.name, scenario.metadata_hash do
            scenario.steps.each do |step|
              Turnip::StepDefinition.execute(self, step.name)
            end
          end
        end
      end
    end
  end
end
