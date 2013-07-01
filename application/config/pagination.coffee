#
#	pagination config
#
#   Twitter Bootstrap markup
#
# enclosing markup:
#
module.exports =
  full_tag_open: '<div class="pagination pagination-centered"><ul>'
  full_tag_close: '</ul></div>'

  first_link: false
  next_link: false
  prev_link: false
  last_link: false
  uri_segment: 3
  first_tag_open: '<li>'
  first_tag_close: '</li>'
  last_tag_open: '<li>'
  last_tag_close: '</li>'
  cur_tag_open: '<li class="active"><span>'
  cur_tag_close: '</span></li>'
  next_tag_open: '<li>'
  next_tag_close: '</li>'
  prev_tag_open: '<li>'
  prev_tag_close: '</li>'
  num_tag_open: '<li>'
  num_tag_close: '</li>'
  page_query_string: false
  query_string_segment: 'per_page'
  display_pages: true
  anchor_class: ''
