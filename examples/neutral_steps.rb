steps_for :neutral do
  use_steps :alignment

  step "the monster has an alignment" do
    self.alignment = 'Neutral'
  end
end
