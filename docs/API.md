

<!-- Start src/Budget.coffee -->

A validation error.

### Properties:

* **string** *parameter* Invalid field name.
* **message** *parameter* Validation constraint message.
* **value** *parameter* Provided value.

Balihoo budget.

Budget validation result.

### Properties:

* **array** *errors*               Errors found during validation process.
* **boolean** *valid*               Indication whether validation was successful or not.

Holds budget related computations.

## validate()

Validation all the specified budgets.

### Return:

* **ValidationResult** a validation result.

## findApplicable(budgets, targetDate)

### Params:

* **array** *budgets*              Sequence of budget objects
* **string** *targetDate*              A date to find budget for.

### Return:

* **number**               A budget amount for the date, or null if no budget applicable for date.

<!-- End src/Budget.coffee -->

