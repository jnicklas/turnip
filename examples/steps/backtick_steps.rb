step "I run :cmd" do |cmd|
  step('I attack it') if cmd == 'killall monsters'
end

placeholder :cmd do
  match /`([^`]*)`/ do |cmd|
    cmd
  end
end

