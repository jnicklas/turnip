# monkey patch for better code in rspec.rb#run - questionable if this is worth
# the effort

module RSpec
  module Core
    class ExampleGroup
      def self.prepare_feature(feature, feature_file)
        before do
          # This is kind of a hack, but it will make RSpec throw way nicer exceptions
          example.metadata[:file_path] = feature_file

          feature.backgrounds.map(&:steps).flatten.each do |step|
            run_step(feature_file, step)
          end
        end
      end

      def self.run_scenarios(feature, feature_file)
        feature.scenarios.each do |scenario|
          describe scenario.name, scenario.metadata_hash do
            it scenario.steps.map(&:description).join(' -> ') do
              scenario.steps.each do |step|
                run_step(feature_file, step)
              end
            end
          end
        end
      end
    end
  end
end