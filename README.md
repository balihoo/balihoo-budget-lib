[![Build Status](https://travis-ci.org/balihoo/balihoo-budget-lib.svg?branch=master)](https://travis-ci.org/balihoo/balihoo-budget-lib)
# Balihoo Budget Library
Utility library to manipulate budgets.

## Installation
```
npm install balihoo-budget-lib
```

## Usage
```javascript

  var budget = require('balihoo-budget-lib');
  var myBudgets = [
    {
        "amount": 500,
        "startDate": "2016-01-01",
        "endDate": "2016-04-30"
    }
  ];

  /** Validates budgets and finds today's budget, throws validation errors if any */

  var amount1 = budget.validateAndFindApplicable(myBudgets);

  /** Validates budgets and finds a specific day's budget, throws validation errors if any */

  var amount2 = budget.validateAndFindApplicable(myBudgets, '2016-02-15');

  /** Example with manual validation handling and specified date. */
  
  var validationResult = budget.validate(myBudgets);
  if (validationResult.valid === true) {
    var amount3 = budget.findApplicable('2016-02-15');
    // ... use amount ...
  } else {
    // ... deal with validationResult.errors ...
  }

```
