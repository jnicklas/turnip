# Turnip

[![Build Status](https://secure.travis-ci.org/jnicklas/turnip.png)](http://travis-ci.org/jnicklas/turnip)

Turnip is a [Gherkin](https://github.com/cucumber/cucumber/wiki/Gherkin)
extension for RSpec. It allows you to write tests in Gherkin and run them
through your RSpec environment. Basically you can write cucumber features in
RSpec.

## Installation

Install the gem

```
gem install turnip
```

Or add it to your Gemfile and run `bundle`.

``` ruby
group :test do
  gem "turnip"
end
```

Now edit the `.rspec` file in your project directory (create it if doesn't
exist), and add the following line:

```
-r turnip
```

## Compatibility

Turnip does not work on Ruby 1.8.X.

## Usage

Add a feature file anywhere in your `spec` directory:

``` cucumber
# spec/acceptance/attack_monster.feature
Feature: Attacking a monster
  Background:
    Given there is a monster

  Scenario: attack the monster
    When I attack it
    Then it should die
```

Now you can run it just like you would run any other rspec spec:

```
rspec spec/acceptance/attack_monster.feature
```

It will automatically be run if you run all your specs with `rake spec` or
`rspec spec`.

Yes, that's really it.

## Defining steps

You might want to define some steps.  Just as in cucumber, your step files
should be named `[something]_steps.rb`.  All files ending in `*steps.rb`
will be automatically required if they are under the Turnip step directory.

The default step directory for Turnip is `spec/`.  You can override this
in your `spec_helper` by setting `Turnip::Config.step_dirs`.  For example:

``` ruby
# spec/spec_helper.rb
RSpec.configure do |config|
  Turnip::Config.step_dirs = 'examples'
  Turnip::StepModule.load_steps
end
```

This would set the Turnip step dirs to `examples/` and automatically load
all `*steps.rb` files anywhere under that directory.

The steps you define in your step files can be global or they can be scoped
to certain features (or scenarios)...

### Global steps
Global steps can be used by any feature/scenario you write since they are
unscoped.  The names must be unique across all step files in the global
namespace.

Define them in your step file like this:

``` ruby
step "there is a monster" do
  @monster = Monster.new
end
```

Note that unlike Cucumber, Turnip does not support regexps in step definitions.
You can however use placeholders in your step definitions, like this:

``` ruby
step "there is a monster called :name" do |name|
  @monster = Monster.new(name)
end
```

You can now put values in this placeholder, either quoted or not:

``` cucumber
Given there is a monster called Jonas
And there is a monster called "Jonas Nicklas"
```

You can also specify alternative words and optional parts of words, like this:

``` ruby
step "there is/are :count monster(s)" do |count|
  @monsters = Array.new(count) { Monster.new }
end
```

That will match both "there is X monster" or "there are X monsters".

You can also define custom step placeholders.  More on that later.

### Scoped steps
Scoped steps help you to organize steps that are specific to
certain features or scenarios.  They only need to be unique within
the scopes being used by the running scenario.

To define scoped steps use `steps_for`:

``` ruby
steps_for :interface do
  step "I do it" do
    ...
  end
end

steps_for :database do
  step "I do it" do
    ...
  end
end
```

Even though the step is named the same, you can now use it in
your feature files like so:

``` cucumber
@interface
Scenario: do it through the interface

@database
Scenario: do it through the database
```

Note that this would still cause an error if you tagged a Scenario
with both `@interface` and `@database` at the same time.

Scoped steps are really just Ruby modules under the covers so you
can do anything you'd normally want to do including defining
helper/utility methods and variables.  Check out `features/alignment_steps.rb`
and `features/evil_steps.rb` for basic examples.

### Reusing steps
When using scoped steps in Turnip, you can tell it to also include steps
defined in another `steps_for` block.  The syntax for that is `uses_steps`:

``` ruby
# dragon_steps.rb
steps_for :dragon do
  attr_accessor :dragon

  def dragon_attack
    dragon * 10
  end

  step "there is a dragon" do
    self.dragon = 1
  end

  step "the dragon attacks for :count hitpoints" do |count|
    dragon_attack.should eq(count)
  end
end

# red_dragon_steps.rb
steps_for :red_dragon do
  use_steps :dragon

  attr_accessor :red_dragon

  def dragon_attack
    attack = super
    if red_dragon
      attack + 10
    else
      attack
    end
  end

  step "it is a fire breathing red dragon" do
    self.red_dragon = 1
  end
end
```

Notice in this example we are making full use of Ruby's modules including
using super to call the included module's version of `dragon_attack`.

### Auto-included steps
By default, Turnip will automatically make steps available to a
feature file if it can find some defined in a scope with the same
name.  For example, given this step file:

``` ruby
# user_signup_steps.rb
steps_for :user_signup do
  step "I am on the homepage" do
    ...
  end
  
  step "I signup with valid info" do
    ...
  end
  
  step "I should see a welcome message" do
  end
end
```

Then the following feature file would run just fine even though we
did not explicitly tag it with `@user_signup`.

``` cucumber
# user_signup.feature
Feature: A user can signup
  Scenario: with email address
    Given I am on the homepage
    When I signup with valid info
    Then I should see a welcome message
```

Note that the `steps_for :user_signup` did not technically have to
appear in the user_signup_steps.rb file; it could have been located
in any `steps.rb` file that was autoloaded by Turnip.

## Custom step placeholders
Do you want to be more specific in what to match in your step
placeholders?  Do you find it bothersome to have to constantly cast them to the
correct type?  Turnip supports custom placeholders to solve both problems, like this:

``` ruby
step "there are :count monsters" do |count|
  count.times { Monster.new(name) }
end

placeholder :count do
  match /\d+/ do |count|
    count.to_i
  end

  match /no/ do
    0
  end
end
```

You would now be able to use these steps like this:

``` cucumber
Given there are 4 monsters
Given there are no monsters
```

Placeholders can extract matches from the regular expressions as well. For
example:

``` ruby
placeholder :monster do
  match /(blue|green|red) (furry|bald) monster/ do |color, hair|
    Monster.new(color, hair)
  end
end
```

These regular expressions must not use anchors, e.g. `^` or `$`. They may not
contain named capture groups, e.g. `(?<color>blue|green)`.

## Using with Capybara

Just require `turnip/capybara` in your `spec_helper`. You can now use the
same tags you'd use in Cucumber to switch between drivers e.g.
`@javascript` or `@selenium`. Your Turnip features will also be run
with the `:type => :request` metadata, so that Capybara is included and
also any other extensions you might want to add.

## License

(The MIT License)

Copyright (c) 2011 Jonas Nicklas

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
