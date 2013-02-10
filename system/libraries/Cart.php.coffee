#+--------------------------------------------------------------------+
#  Cart.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Shopping Cart Class
#
# @package		Exspresso
# @subpackage	Libraries
# @category	Shopping Cart
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/libraries/cart.html
#
class Exspresso_Cart
  
  #  These are the regular expression rules that we use to validate the product ID and product name
  product_id_rules: '\.a-z0-9_-'#  alpha-numeric, dashes, underscores, or periods
  product_name_rules: '\.\:\-_ a-z0-9'#  alpha-numeric, dashes, underscores, colons or periods
  
  #  Private variables.  Do not change!
  Exspresso: {}
  _cart_contents: {}
  
  
  #
  # Shopping Class Constructor
  #
  # The constructor loads the Session class, used to store the shopping cart contents.
  #
  __construct($params = {})
  {
  #  Set the super object to a local variable for use later
  @Exspresso = Exspresso
  
  #  Are any config settings being passed manually?  If so, set them
  $config = {}
  if count($params) > 0
    for $key, $val of $params
      $config[$key] = $val
      
    
  
  #  Load the Sessions class
  @Exspresso.load.library('session', $config)
  
  #  Grab the shopping cart array from the session table, if it exists
  if @Exspresso.session.userdata('cart_contents') isnt false
    @_cart_contents = @Exspresso.session.userdata('cart_contents')
    
  else 
    #  No cart exists so we'll set some base values
    @_cart_contents['cart_total'] = 0
    @_cart_contents['total_items'] = 0
    
  
  log_message('debug', "Cart Class Initialized")
  }
  
  #
  # Insert items into the cart and save it to the session table
  #
  # @access	public
  # @param	array
  # @return	bool
  #
  insert : ($items = {}) ->
    #  Was any cart data passed? No? Bah...
    if not is_array($items) or count($items) is 0
      log_message('error', 'The insert method must be passed an array containing data.')
      return false
      
    
    #  You can either insert a single product using a one-dimensional array,
    #  or multiple products using a multi-dimensional one. The way we
    #  determine the array type is by looking for a required array key named "id"
    #  at the top level. If it's not found, we will assume it's a multi-dimensional array.
    
    $save_cart = false
    if $items['id']? 
      if @_insert($items) is true
        $save_cart = true
        
      
    else 
      for $val in $items
        if is_array($val) and $val['id']? 
          if @_insert($val) is true
            $save_cart = true
            
          
        
      
    
    #  Save the cart data if the insert was successful
    if $save_cart is true
      @_save_cart()
      return true
      
    
    return false
    
  
  #
  # Insert
  #
  # @access	private
  # @param	array
  # @return	bool
  #
  _insert : ($items = {}) ->
    #  Was any cart data passed? No? Bah...
    if not is_array($items) or count($items) is 0
      log_message('error', 'The insert method must be passed an array containing data.')
      return false
      
    
    #  --------------------------------------------------------------------
    
    #  Does the $items array contain an id, quantity, price, and name?  These are required
    if not $items['id']?  or  not $items['qty']?  or  not $items['price']?  or  not $items['name']? 
      log_message('error', 'The cart array must contain a product ID, quantity, price, and name.')
      return false
      
    
    #  --------------------------------------------------------------------
    
    #  Prep the quantity. It can only be a number.  Duh...
    $items['qty'] = trim(preg_replace('/([^0-9])/i', '', $items['qty']))
    #  Trim any leading zeros
    $items['qty'] = trim(preg_replace('/(^[0]+)/i', '', $items['qty']))
    
    #  If the quantity is zero or blank there's nothing for us to do
    if not is_numeric($items['qty']) or $items['qty'] is 0
      return false
      
    
    #  --------------------------------------------------------------------
    
    #  Validate the product ID. It can only be alpha-numeric, dashes, underscores or periods
    #  Not totally sure we should impose this rule, but it seems prudent to standardize IDs.
    #  Note: These can be user-specified by setting the $this->product_id_rules variable.
    if not preg_match("/^[" + @product_id_rules + "]+$/i", $items['id'])
      log_message('error', 'Invalid product ID.  The product ID can only contain alpha-numeric characters, dashes, and underscores')
      return false
      
    
    #  --------------------------------------------------------------------
    
    #  Validate the product name. It can only be alpha-numeric, dashes, underscores, colons or periods.
    #  Note: These can be user-specified by setting the $this->product_name_rules variable.
    if not preg_match("/^[" + @product_name_rules + "]+$/i", $items['name'])
      log_message('error', 'An invalid name was submitted as the product name: ' + $items['name'] + ' The name can only contain alpha-numeric characters, dashes, underscores, colons, and spaces')
      return false
      
    
    #  --------------------------------------------------------------------
    
    #  Prep the price.  Remove anything that isn't a number or decimal point.
    $items['price'] = trim(preg_replace('/([^0-9\.])/i', '', $items['price']))
    #  Trim any leading zeros
    $items['price'] = trim(preg_replace('/(^[0]+)/i', '', $items['price']))
    
    #  Is the price a valid number?
    if not is_numeric($items['price'])
      log_message('error', 'An invalid price was submitted for product ID: ' + $items['id'])
      return false
      
    
    #  --------------------------------------------------------------------
    
    #  We now need to create a unique identifier for the item being inserted into the cart.
    #  Every time something is added to the cart it is stored in the master cart array.
    #  Each row in the cart array, however, must have a unique index that identifies not only
    #  a particular product, but makes it possible to store identical products with different options.
    #  For example, what if someone buys two identical t-shirts (same product ID), but in
    #  different sizes?  The product ID (and other attributes, like the name) will be identical for
    #  both sizes because it's the same shirt. The only difference will be the size.
    #  Internally, we need to treat identical submissions, but with different options, as a unique product.
    #  Our solution is to convert the options array to a string and MD5 it along with the product ID.
    #  This becomes the unique "row ID"
    if $items['options']?  and count($items['options']) > 0
      $rowid = md5($items['id'] + implode('', $items['options']))
      
    else 
      #  No options were submitted so we simply MD5 the product ID.
      #  Technically, we don't need to MD5 the ID in this case, but it makes
      #  sense to standardize the format of array indexes for both conditions
      $rowid = md5($items['id'])
      
    
    #  --------------------------------------------------------------------
    
    #  Now that we have our unique "row ID", we'll add our cart items to the master array
    
    #  let's unset this first, just to make sure our index contains only the data from this submission
    delete @_cart_contents[$rowid]
    
    #  Create a new index with our new row ID
    @_cart_contents[$rowid]['rowid'] = $rowid
    
    #  And add the new items to the cart array
    for $key, $val of $items
      @_cart_contents[$rowid][$key] = $val
      
    
    #  Woot!
    return true
    
  
  #
  # Update the cart
  #
  # This function permits the quantity of a given item to be changed.
  # Typically it is called from the "view cart" page if a user makes
  # changes to the quantity before checkout. That array must contain the
  # product ID and quantity for each item.
  #
  # @access	public
  # @param	array
  # @param	string
  # @return	bool
  #
  update : ($items = {}) ->
    #  Was any cart data passed?
    if not is_array($items) or count($items) is 0
      return false
      
    
    #  You can either update a single product using a one-dimensional array,
    #  or multiple products using a multi-dimensional one.  The way we
    #  determine the array type is by looking for a required array key named "id".
    #  If it's not found we assume it's a multi-dimensional array
    $save_cart = false
    if $items['rowid']?  and $items['qty']? 
      if @_update($items) is true
        $save_cart = true
        
      
    else 
      for $val in $items
        if is_array($val) and $val['rowid']?  and $val['qty']? 
          if @_update($val) is true
            $save_cart = true
            
          
        
      
    
    #  Save the cart data if the insert was successful
    if $save_cart is true
      @_save_cart()
      return true
      
    
    return false
    
  
  #
  # Update the cart
  #
  # This function permits the quantity of a given item to be changed.
  # Typically it is called from the "view cart" page if a user makes
  # changes to the quantity before checkout. That array must contain the
  # product ID and quantity for each item.
  #
  # @access	private
  # @param	array
  # @return	bool
  #
  _update : ($items = {}) ->
    #  Without these array indexes there is nothing we can do
    if not $items['qty']?  or  not $items['rowid']?  or  not @_cart_contents[$items['rowid']]? 
      return false
      
    
    #  Prep the quantity
    $items['qty'] = preg_replace('/([^0-9])/i', '', $items['qty'])
    
    #  Is the quantity a number?
    if not is_numeric($items['qty'])
      return false
      
    
    #  Is the new quantity different than what is already saved in the cart?
    #  If it's the same there's nothing to do
    if @_cart_contents[$items['rowid']]['qty'] is $items['qty']
      return false
      
    
    #  Is the quantity zero?  If so we will remove the item from the cart.
    #  If the quantity is greater than zero we are updating
    if $items['qty'] is 0
      delete @_cart_contents[$items['rowid']]
      
    else 
      @_cart_contents[$items['rowid']]['qty'] = $items['qty']
      
    
    return true
    
  
  #
  # Save the cart array to the session DB
  #
  # @access	private
  # @return	bool
  #
  _save_cart :  ->
    #  Unset these so our total can be calculated correctly below
    delete @_cart_contents['total_items']
    delete @_cart_contents['cart_total']
    
    #  Lets add up the individual prices and set the cart sub-total
    $total = 0
    for $key, $val of @_cart_contents
      #  We make sure the array contains the proper indexes
      if not is_array($val) or  not $val['price']?  or  not $val['qty']? 
        continue
        
      
      $total+=($val['price'] * $val['qty'])
      
      #  Set the subtotal
      @_cart_contents[$key]['subtotal'] = (@_cart_contents[$key]['price'] * @_cart_contents[$key]['qty'])
      
    
    #  Set the cart total and total items.
    @_cart_contents['total_items'] = count(@_cart_contents)
    @_cart_contents['cart_total'] = $total
    
    #  Is our cart empty?  If so we delete it from the session
    if count(@_cart_contents)<=2
      @Exspresso.session.unset_userdata('cart_contents')
      
      #  Nothing more to do... coffee time!
      return false
      
    
    #  If we made it this far it means that our cart has data.
    #  Let's pass it to the Session class so it can be stored
    @Exspresso.session.set_userdata('cart_contents':@_cart_contents)
    
    #  Woot!
    return true
    
  
  #
  # Cart Total
  #
  # @access	public
  # @return	integer
  #
  total :  ->
    return @_cart_contents['cart_total']
    
  
  #
  # Total Items
  #
  # Returns the total item count
  #
  # @access	public
  # @return	integer
  #
  total_items :  ->
    return @_cart_contents['total_items']
    
  
  #
  # Cart Contents
  #
  # Returns the entire cart array
  #
  # @access	public
  # @return	array
  #
  contents :  ->
    $cart = @_cart_contents
    
    #  Remove these so they don't create a problem when showing the cart table
    delete $cart['total_items']
    delete $cart['cart_total']
    
    return $cart
    
  
  #
  # Has options
  #
  # Returns TRUE if the rowid passed to this function correlates to an item
  # that has options associated with it.
  #
  # @access	public
  # @return	array
  #
  has_options : ($rowid = '') ->
    if not @_cart_contents[$rowid]['options']?  or count(@_cart_contents[$rowid]['options']) is 0
      return false
      
    
    return true
    
  
  #
  # Product options
  #
  # Returns the an array of options, for a particular product row ID
  #
  # @access	public
  # @return	array
  #
  product_options : ($rowid = '') ->
    if not @_cart_contents[$rowid]['options']? 
      return {}
      
    
    return @_cart_contents[$rowid]['options']
    
  
  #
  # Format Number
  #
  # Returns the supplied number with commas and a decimal point.
  #
  # @access	public
  # @return	integer
  #
  format_number : ($n = '') ->
    if $n is ''
      return ''
      
    
    #  Remove anything that isn't a number or decimal point.
    $n = trim(preg_replace('/([^0-9\.])/i', '', $n))
    
    return number_format($n, 2, '.', ',')
    
  
  #
  # Destroy the cart
  #
  # Empties the cart and kills the session
  #
  # @access	public
  # @return	null
  #
  destroy :  ->
    delete @_cart_contents
    
    @_cart_contents['cart_total'] = 0
    @_cart_contents['total_items'] = 0
    
    @Exspresso.session.unset_userdata('cart_contents')
    
  
  
  

register_class 'Exspresso_Cart', Exspresso_Cart
module.exports = Exspresso_Cart
#  END Cart Class

#  End of file Cart.php 
#  Location: ./system/libraries/Cart.php 