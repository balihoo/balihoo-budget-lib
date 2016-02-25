[![Build Status](https://travis-ci.org/balihoo/balihoo-budget-lib.svg?branch=master)](https://travis-ci.org/balihoo/balihoo-budget-lib)
# Balihoo Budget Library
Utility library to manipulate budgets.

## Installation
```
npm install balihoo-budget-lib
```

## Usage
[API docs](docs/API.md)

#### Example

```javascript

  var budget = require('balihoo-budget-lib');
  var myBudgets = [
    {
        "amount": 500,
        "startDate": "2016-01-01",
        "endDate": "2016-04-30"
    }
  ];

  var validationResult = budget.validate(myBudgets);
  if (validationResult.valid === true) {
    var amount = budget.findApplicable('2016-02-15');
    // ... use amount ...
  } else {
    // ... deal with validationResult.errors ...
  }

```

## Development

#### Requirements
```
sudo npm install -g gulp
```

#### Launch dev mode!
```
gulp
```
