steps_for :alignment do
  attr_accessor :alignment

  step "that alignment should be :alignment" do |expected_alignment|
    alignment.should eq(expected_alignment)
  end
end
