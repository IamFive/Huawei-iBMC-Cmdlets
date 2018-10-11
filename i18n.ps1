$i18n = Data {
  #culture="en-US"
  ConvertFrom-StringData @'
  helloWorld = Hello, World.
'@
}

# Not necessary for now
# Import-LocalizedData -BindingVariable i18n