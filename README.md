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

## Development

* Source hosted at [GitHub](http://github.com/jnicklas/turnip).
* Please direct questions, discussion or problems to the [mailing list](http://groups.google.com/group/ruby-turnip).
  Please do not open an issue on GitHub if you have a question.
* If you found a reproducible bug, open a [GitHub Issue](http://github.com/jnicklas/turnip/issues) to submit a bug report.
* Please do not contact any of the maintainers directly, unless you have found a security related issue.

Pull requests are very welcome (and even better than bug reports)!
Please create a topic branch for every separate change you make.

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

You can define steps on any module:

``` ruby
module MonsterSteps
  step "there is a monster" do
    @monster = Monster.new
  end
end
```

You can now include this module in RSpec:

``` ruby
RSpec.configure { |c| c.include MonsterSteps }
```

Steps are implemented as regular Ruby methods under the hood, so you can
use Ruby's normal inheritance chain to mix and match steps.

### Global steps

Turnip has a special module called `Turnip::Steps`, which is automatically
included in RSpec. If you add steps to this module, they are available in all
your features. As a convenience, there is a shortcut to doing this, just call
`step` in the global namespace like this:

``` ruby
step "there is a monster" do
  @monster = Monster.new
end
```

### Placeholders

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

You can also define custom step placeholders. More on that later.

### Scoped steps

Since steps are defined on modules, you can pick and choose which of them are
available in which feature. This can be extremely useful if you have a large
number of steps, and do not want them to potentially conflict.

If you had some scenarios which talk to the database directly, and some which
go through a user interface, you could implement it as follows:

``` ruby
module InterfaceSteps
  step "I do it" do
    ...
  end
end

module DatabaseSteps
  step "I do it" do
    ...
  end
end

RSpec.configure do |config|
  config.include InterfaceSteps, :interface => true
  config.include DatabaseSteps, :database => true
end
```

Turnip turns tags into RSpec metadata, so you can use RSpec's conditional
include feature to include these steps only for those scenarios tagged the
appropriate way. So even though the step is named the same, you can now use it
in your feature files like so:

``` cucumber
@interface
Scenario: do it through the interface

@database
Scenario: do it through the database
```

Be careful though not to tag a feature with both `@interface` and `@database`
in this example. Since steps use the Ruby inheritance chain, the step which is
included last will "win", just like any other Ruby method. This might not be
what you expect.

Since this pattern of creating a module and including it for a specific tag
is very common, we have created a handy shortcut for it:

``` ruby
steps_for :interface do
  step "I do it" do
    ...
  end
end
```

Check out [features/alignment_steps.rb](https://github.com/jnicklas/turnip/blob/master/examples/steps/alignment_steps.rb)
                                        
for an example.

### Where to place steps

All files ending in `*steps.rb` will be automatically required if they are
under the Turnip step directory. The default step directory for Turnip is
`spec/`. You can override this in your `spec_helper` by setting
`Turnip::Config.step_dirs`. For example:

``` ruby
# spec/spec_helper.rb
Turnip.step_dirs = ['spec/examples']
```

This would set the Turnip step dirs to `spec/examples/`. This is relative to the APP_ROOT, *not* the `spec/` directory itself.
( e.g this means the directory checked is #{APP_ROOT}/spec/examples/ ) 
All `*steps.rb` files anywhere under the `spec/examples/` directory would then be autoloaded.

### Calling steps from other steps

You can also call steps from other steps. This is done by just calling `step
"name_of_the_step"`, so for instance if you have:

``` ruby
step "a random step" do
  @value = 1
end

step "calling a step" do
  step "a random step"
  @value += 1
end
```

Now if you use the step `calling a step` in any Scenario, then the value of
`@value` will be 2 afterwards as it first executes the code defined for the step
`a random step`. You can think of it as a simple method call.

### Calling steps manually

This is a more esoteric feature of Turnip, of use mostly to people who want to
do crazy stuff. The `Turnip::Execute` module has a method called `step`, this
method executes a step, given a string as it might appear in a feature file.

For example:

``` ruby
class Monster
  include Turnip::Execute

  step("sing a song") { "Arrrghghggh" }
  step("eat :count villager(s)") { Villager.eat(count) }
end

monster = Monster.new
monster.step("sing a song")
monster.step("eat 1 villager")
monster.step("eat 5 villagers")
```

Note that in this case `step` from `Turnip::Execute` is an *instance* method,
whereas `step` used to define the step is a *class* method, they are *not* the
same method.

## Custom step placeholders

Do you want to be more specific in what to match in your step placeholders? Do
you find it bothersome to have to constantly cast them to the correct type?
Turnip supports custom placeholders to solve both problems, like this:

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

## Table Steps

Turnip also supports steps that take a table as a parameter similar to Cucumber:

``` cucumber
Scenario: This is a feature with a table
  Given there are the following monsters:
    | Name    | Hitpoints |
    | Blaaarg | 23        |
    | Moorg   | 12        |
  Then "Blaaarg" should have 23 hitpoints
  And "Moorg" should have 12 hitpoints
```
The table is a `Turnip::Table` object which works in much the same way as Cucumber's
`Cucumber::Ast::Table` objects.

E.g. converting the `Turnip::Table` to an array of hashes:

``` ruby
step "there are the following monsters:" do |table|
  @monsters = {}
  table.hashes.each do |hash|
    @monsters[hash['Name']] = hash['Hitpoints'].to_i
  end
end
```

## Using with Capybara

Just require `turnip/capybara` in your `spec_helper`. You can now use the same
tags you'd use in Cucumber to switch between drivers e.g.  `@javascript` or
`@selenium`. Your Turnip features will also be run with the `:type => :request`
metadata, so that Capybara is included and also any other extensions you might
want to add.

## License

(The MIT License)

Copyright (c) 2011-2012 Jonas Nicklas

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the 'Software'), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
