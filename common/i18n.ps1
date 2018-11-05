$bundle = Data {
  #culture="en-US"
  ConvertFrom-StringData @'
  MSG_WAIT_PROGRESS_TITLE = Waiting multiple thread results
  MSG_PROGRESS_PERCENT = Percent Complete
  MSG_PROGRESS_COMPLETE = Task Complete
  MSG_PROGRESS_FAILED = Task Failed

  FAIL_NO_USER_WITH_NAME_EXISTS = Failure: No user with name "{0}" exists
  FAIL_NO_UPDATE_PARAMETER = Failure: at least one update parameter must be set
  FAIL_NO_PRIVILEGE = Failure: you do not have the required permissions to perform this operation
  FAIL_INTERNAL_SERVICE = Failure: the request failed due to an internal service error
  FAIL_NOT_SUPPORT = Failure: the server did not support the functionality required
  FAIL_TO_MODIFY_ALL = Failure: Fail to apply all submit settings, got failures:

  ERROR_INVALID_CREDENTIALS = Error: Invalid credentials
  ERROR_PARAMETER_EMPTY = Error: parameter "{0}" should not be null or empty
  ERROR_PARAMETER_ILLEGAL = Error: parameter "{0}" is illegal, please check it
  ERROR_PARAMETER_COUNT_DIFFERERNT = Error: The array size of parameter "{1}" should be one or the same as parameter "{0}"
  ERROR_PARAMETER_ARRAY_EMPTY = Error: Array parameter "{0}" should not be null or empty or contains null element.
  ERROR_ILLEGAL_BOOT_SEQ = Error: BootSequence parameter {0} is illegal, it should exactly contains four Boot devices (HDD, Cd, Pxe, Others)
  ERROR_NO_UPDATE_PAYLOAD = Error: nothing to update, at least one update property must be specified
'@
}

# Not necessary for now
# Import-LocalizedData -BindingVariable bundles

function Get-i18n($key) {
  return $bundle[$Key]
}