$bundle = Data {
  #culture="en-US"
  ConvertFrom-StringData @'
  MSG_WAIT_PROGRESS_TITLE = Waiting multiple thread results
  MSG_WAIT_PROGRESS_PERCENT = Percent Complete
  ERROR_INVALID_CREDENTIALS = Failure: Invalid credentials
  ERROR_PARAMETER_EMPTY = Failure: parameter "{0}" should not be null or empty
  ERROR_PARAMETER_ILLEGAL = Failure: parameter "{0}" is illegal, please check it
  ERROR_PARAMETER_COUNT_DIFFERERNT = Failure: The array size of parameter "{1}" should be one or the same as parameter "{0}"
  ERROR_PARAMETER_ARRAY_EMPTY = Failure: Array parameter "{0}" should not be null or empty or contains null element.
'@
}

  # 'MSG_PROGRESS_ACTIVITY'='Waiting multiple thread results'
  # 'MSG_PROGRESS_STATUS'='Percent Complete'
  # 'MSG_SENDING_TO'='Sending to {0}'
  # 'MSG_FAIL_HOSTNAME'='DNS name translation not available for {0} - Host name left blank.'
  # 'MSG_FAIL_IPADDRESS'='Invalid Hostname: IP Address translation not available for hostname {0}.'
  # 'MSG_PARAMETER_INVALID_TYPE'="Error : `"{0}`" is not supported for parameter `"{1}`"."
  # 'MSG_INVALID_USE'='Error : Invalid use of cmdlet. Please check your input again'
  # 'MSG_INVALID_RANGE'='Error : The Range value is invalid'
  # 'MSG_INVALID_PARAMETER'="`"{0}`" is invalid, it will be ignored."
  # 'MSG_INVALID_TIMEOUT'='Error : The Timeout value is invalid'
  # 'MSG_FIND_LONGTIME'='It might take a while to search for all the HPE Redfish sources if the input is a very large range. Use Verbose for more information.'
  # 'MSG_USING_THREADS_FIND'='Using {0} threads for search.'
  # 'MSG_PING'='Pinging {0}'
  # 'MSG_PING_FAIL'='No system responds at {0}'
  # 'MSG_FIND_NO_SOURCE'='No HPE Redfish source at {0}'
  # 'MSG_INVALID_CREDENTIALS'='Invalid credentials'
  # 'MSG_SCHEMA_NOT_FOUND'='Schema not found for {0}'
  # 'MSG_INVALID_ODATA_ID'='The odata id is invalid'
  # 'MSG_FORMATDIR_LOCATION'='Location'
  # 'MSG_PARAMETER_MISSING'="Error : Invalid use of cmdlet. `"{0}`" parameter is missing"
  # 'MSG_NO_REDFISH_DATA'='{0} : HPE Redfish data not found'

# Not necessary for now
# Import-LocalizedData -BindingVariable bundles