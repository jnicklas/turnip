steps_for :runner do

  step 'I start as a beginner runner' do |level|
    enable_steps_for(:beginner_level)
  end

  step 'I become an advanced runner' do |level|
    disable_steps_for(:beginner_level)
    enable_steps_for(:advanced_level)
  end

end

steps_for :beginner_level do

  def calculate_distance(minutes)
    @distance = minutes * 0.1
  end

  step 'I run for :num minutes' do |minutes|
    calculate_distance(minutes.to_i)
  end

  step 'I should have run :num miles' do |miles|
    miles.to_i.should eq(@distance)
  end

end

steps_for :advanced_level do

  def calculate_distance(minutes)
    @distance = minutes * 0.2
  end

  step 'I run for :num minutes' do |minutes|
    calculate_distance(minutes.to_i)
  end

  step 'I should have run :num miles' do |miles|
    miles.to_i.should eq(@distance)
  end

end
