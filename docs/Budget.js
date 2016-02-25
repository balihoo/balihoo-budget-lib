

<!-- Start lib/Budget.js -->

Result of budgets validation.

### Properties:

* **array** *errors*             An array of validation errors.
* **boolean** *valid*             Indicates whether errors were found or not.

Error thrown when budgets dates overlaps.

### Properties:

* **string** *date1*             First date in error.
* **string** *date2*             Second date in error.
* **string** *message*             A message to explain the error.

Error thrown when budgets are invalid.

### Properties:

* **ValidationResult** *result* 

Holds budget related computations.

## validate()

Validation all the specified budgets.

### Return:

* **ValidationResult** a validation result.

## findApplicable(budgets, targetDate)

### Params:

* **array** *budgets*            An array of budget object.
* **string** *targetDate*            A date to find budget for.

### Return:

* **number**             A budget amount for the date, or null if no budget applicable for date.

## validateAndFindApplicable(budgets, targetDate)

### Params:

* **array** *budgets*            An array of budget object.
* **string** *targetDate*            A date to find budget for.

### Return:

* **number**             A budget amount for the date.

Finds overlapping budget dates and throw an exception
    on the first encountered occurence.

<!-- End lib/Budget.js -->

