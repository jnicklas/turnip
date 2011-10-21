# Turnip

Turnip is a [Gherkin](https://github.com/cucumber/cucumber/wiki/Gherkin) extension for RSpec. It allows you to write tests in Gherkin and run them through your RSpec environment. Basically you can write cucumber features in RSpec.

## DISCLAIMER, READ THIS!!!

Turnip is a proof of concept, there are currently NO TESTS, and there is a lot of cucumber's syntax it does NOT support. There are currently no tables, multiline string or scenario outlines.

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

Now edit the `.rspec` file in your project directory (create it if doesn't exist), and add the following line:

```
-r turnip
```

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

It will automatically be run if you run all your specs with `rake spec` or `rspec spec`.

Yes, that's really it.

## Defining steps

You might want to define some steps. You can put them anywhere. Turnip automatically requires your `spec_helper`, so you can add them there or put them in separate files (recommended). Define them like this:

``` ruby
step "there is a monster" do
  @monster = Monster.new
end
```

Note that unlike Cucumber, Turnip does not support regexps in step definitions.
