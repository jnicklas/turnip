module Turnip
  def self.run(content)
    builder = Turnip::Builder.new
    formatter = Gherkin::Formatter::TagCountFormatter.new(builder, {})
    parser = Gherkin::Parser::Parser.new(formatter, true, "root", false)
    parser.parse(content, nil, 0)

    builder.features.each do |feature|
      describe feature.name do
        feature.backgrounds.each do |background|
          before do
            background.steps.each do |step|
              Turnip::Steps.execute_step(self, step.name)
            end
          end
        end
        feature.scenarios.each do |scenario|
          it scenario.name, scenario.metadata_hash do
            scenario.steps.each do |step|
              Turnip::Steps.execute_step(self, step.name)
            end
          end
        end
      end
    end
  end
end
