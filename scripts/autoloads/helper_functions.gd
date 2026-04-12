class_name HelperFunctions
extends Object
## General functions not included by Godot that can be helpfull in many places
##
## It is not intended to instatiate or extend this class. 


## Removes and returns the element of the array at index position. 
## If negative, position is considered relative to the end of the array.[br]
## Returns [code]null[/code] if the array is empty. 
## If position is out of bounds, an error message is also generated.[br]
## [br]
## [b]Note:[/b] This is an O(1) [method Array.pop_at] that does not preserve element order.
static func swap_pop(array: Array, idx: int) -> Variant:
	if array.size() == 0:
		return null
	if idx < 0:
		idx += array.size()
	if idx < 0 or idx >= array.size():
		push_error("Index is out of bounds")
		return null
	var removed_element = array[idx]
	if idx != array.size() - 1:
		array[idx] = array[-1]
	array.pop_back()
	return removed_element
