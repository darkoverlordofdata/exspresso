#
# Form Validation Groups
#
module.exports =
  #
  # login form validation rules
  #
  login: [
    {
      field: 'username'
      label: 'User Name'
      rules: 'required'
    }
    {
      field: 'password'
      label: 'Password'
      rules: 'required'
    }
  ]

