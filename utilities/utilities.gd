extends Node
class_name utilities

static func PrintTree(root : Node, indent : String = ">"):
	_printNode(root, indent)
	
static func _printNode(node : Node, indent : String = ">", level : int = 0):
	var prefix = ""
	for i in range(level):
		prefix += indent
	print(prefix, node.name)
	for child in node.get_children(true):
		_printNode(child, indent, level + 1)
