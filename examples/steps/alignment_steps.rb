module Alignment
  attr_accessor :alignment

  step "that alignment should be :alignment" do |expected_alignment|
    alignment.should eq(expected_alignment)
  end
end

steps_for :evil do
  include Alignment

  step "the monster has an alignment" do
    self.alignment = 'Evil'
  end
end

steps_for :neutral do
  include Alignment

  step "the monster has an alignment" do
    self.alignment = 'Neutral'
  end
end
