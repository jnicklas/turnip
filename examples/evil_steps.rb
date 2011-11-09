steps_for :evil do
  use_steps :alignment

  step "the monster has an alignment" do
    self.alignment = 'Evil'
  end
end
