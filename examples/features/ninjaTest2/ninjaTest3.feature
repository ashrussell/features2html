Feature: be a ninja3
 As a tester at I need to be able have shiny ninja powers

Rule: some rule about being shiny home

Scenario: working at home
	Given I need to make feature docs
	When I beep boop the computer
	Then shiny magic happens

Rule: some rule about being shiny the office
	
Scenario: working from the office
	Given I need to make feature docs
	When I beep boop the computer
	Then shiny magic happens
	
Scenario Outline: eating
  Given there are <start> cucumbers
  When I eat <eat> cucumbers
  Then I should have <left> cucumbers

  Examples:
    | start | eat | left |
    |    12 |   5 |    7 |
    |    20 |   5 |   15 |