

<!-- Start src/Budget.coffee -->

<!-- End src/Budget.coffee -->

<!-- Start src/BudgetUtil.coffee -->

## validate(budgets)

Validates all budgets in the specified list.

### Params:

* **Array.\<Budget>** *budgets* - A list of budgets to validate.

### Return:

* **ValidationResult** Budget validation result.

### Example:
        var BudgetUtil = require('balihoo-budget-lib');
        var myBudgets = [
          {
              "amount": 500,
              "startDate": "2016-01-01",
              "endDate": "2016-04-30"
          }
        ];
        var validation = BudgetUtil.validate(myBudgets);
        if (validation.valid === true) {
          // deal with valid budgets!
        }

## findApplicable(budgets, targetDate)

Finds the applicable budget amount within the given budgets.

### Params:

* **Array.\<Budget>** *budgets* - A list of valid budget objects.
* **String** *targetDate* - A MomentJS compatible date string.

### Return:

* **Number** The applicable budget amount for the specified date.

### Examples
      var BudgetUtil = require('balihoo-budget-lib');
      var myBudgets = [
        {
            "amount": 500,
            "startDate": "2016-01-01",
            "endDate": "2016-04-30"
        }
      ];
      // "myBudgets" should be validated at this point
      var amount = BudgetUtil.findApplicable(myBudgets, '2016-02-18');
      // deal with amount...

## Budget

### Properties:

* **Number** *amount* - Available amount of money for the budget period.
* **String** *startDate* - MomentJS-compatible date for budget period start.
* **String** *endDate* - MomentJS-compatible date for budget period end.

## ValidationResult

### Properties:

* **Array.\<ValidationError>** *errors* - Details for all validation errors.
* **Boolean** *valid* - Whether all budgets are valid or not.

## ValidationError

### Properties:

* **String** *parameter* - Name of bad property.
* **String** *message* - Details about the failed validation.
* **String** *value* - Provided value.

<!-- End src/BudgetUtil.coffee -->

<!-- Start src/ValidationError.coffee -->

<!-- End src/ValidationError.coffee -->

