#+--------------------------------------------------------------------+
#| pagination.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#	pagination config
#
#   Twitter Bootstrap markup
#
# enclosing markup:
#
exports['full_tag_open'] = '<div class="pagination pagination-centered"><ul>'
exports['full_tag_close'] = '</ul></div>'

exports['first_link'] = false
exports['next_link'] = false
exports['prev_link'] = false
exports['last_link'] = false
exports['uri_segment'] = 3
exports['first_tag_open'] = '<li>'
exports['first_tag_close'] = '</li>'
exports['last_tag_open'] = '<li>'
exports['last_tag_close'] = '</li>'
exports['cur_tag_open'] = '<li class="active"><span>'
exports['cur_tag_close'] = '</span></li>'
exports['next_tag_open'] = '<li>'
exports['next_tag_close'] = '</li>'
exports['prev_tag_open'] = '<li>'
exports['prev_tag_close'] = '</li>'
exports['num_tag_open'] = '<li>'
exports['num_tag_close'] = '</li>'
exports['page_query_string'] = false
exports['query_string_segment'] = 'per_page'
exports['display_pages'] = true
exports['anchor_class'] = ''

# End of file pagination.coffee
# Location: .application/config/pagination.coffee