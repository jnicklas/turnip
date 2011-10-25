# Turnip

Turnip is a [Gherkin](https://github.com/cucumber/cucumber/wiki/Gherkin)
extension for RSpec. It allows you to write tests in Gherkin and run them
through your RSpec environment. Basically you can write cucumber features in
RSpec.

## DISCLAIMER, READ THIS!!!

Turnip is a proof of concept, there are currently VERY FEW TESTS, and there is
a lot of cucumber's syntax it does NOT support. There are currently no tables,
multiline string or scenario outlines.

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

You might want to define some steps. You can put them anywhere. Turnip
automatically requires your `spec_helper`, so you can add them there or put
them in separate files (recommended). Define them like this:

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

## Defining placeholders

But what if you want to be more specific in what to match in those
placeholders, and it is bothersome to have to constantly cast them to the
correct type. Turnip's placeholder solve both problems, like this:

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

Just require `turnip/capybara`, either in your `spec_helper` or by
adding `-r turnip/capybara` to your `.rspec` file. You can now use the
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
