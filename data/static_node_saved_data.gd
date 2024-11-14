## For nodes that will just stay where they are that we need to find and set up.
## We don't recreate them because other initialization logic may rely on them having the
## same pointer.
class_name StaticNodeSavedData
extends BaseNodeSavedData

@export var node_path: String
