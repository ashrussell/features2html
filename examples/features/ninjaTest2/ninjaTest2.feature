Feature: be a ninja2
 As a tester at I need to be able have ninja powers

Rule: some rule about being at home

Scenario: working at home
	Given I need to make feature docs
	When I beep boop the computer
	Then magic happens

Rule: some rule about being in the office
	
Scenario: working from the office
	Given I need to make feature docs
	When I beep boop the computer
	Then magic happens
	
Scenario Outline: eating
  Given there are <start> cucumbers
  When I eat <eat> cucumbers
  Then I should have <left> cucumbers

  Examples:
    | start | eat | left |
    |    12 |   5 |    7 |
    |    20 |   5 |   15 |