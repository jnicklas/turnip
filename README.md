# Turnip

[![Build Status](https://secure.travis-ci.org/jnicklas/turnip.png)](http://travis-ci.org/jnicklas/turnip)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/jnicklas/turnip)

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
-r turnip/rspec
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

Turnip automatically loads your `spec_helper` file. From there you can place
your steps wherever you want, and load them however you like. For example, if
you were to put your steps in `spec/steps`, you could load them like this:

``` ruby
Dir.glob("spec/steps/**/*steps.rb") { |f| load f, true }
```

Before loading your `spec_helper`, Turnip also tries to load a file called
`turnip_helper` where you can setup anything specific to your turnip examples.
You might find it beneficial to load your steps from this file so that they
don't have to be loaded when you run your other tests.

### Calling steps from other steps

Since steps are Ruby methods you can call them like other Ruby methods.
However, since the step description likely contains spaces and other special
characters, you will probably have to use `send` to call the step:

``` ruby
step "the value is :num" do |num|
  @value = num
end

step "the value is twice as much as :num" do |num|
  send "the value is :num", num * 2
end
```

If you use the second step, it will call into the first step, sending in the
doubled value.

Sometimes you will want to call the step just like you would from your feature
file, in that case you can use the `step` method:

``` ruby
step "the value is :num" do |num|
  @value = num
end

step "the value is the magic number"
  step "the value is 3"
end
```

### Methods as steps

You can mark an existing method as a step. This will make it available in your
Turnip features. For example:

``` ruby
module MonsterSteps
  def create_monster(name)
    @monster = Monster.new(:name => name)
  end
  step :create_monster, "there is a monster called :name"
end
```

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
`@selenium`. Your Turnip features will also be run with the `:type => :feature`
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
