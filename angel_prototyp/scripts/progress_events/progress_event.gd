class_name ProgressEvent
extends Resource
## Progress Event base class.
##
## Extend this and override execute() to implement an action.
## If it needs params, create a subclass and pass it.


## At what percentage of the total progress the even should trigger,
## as decimal, e.g. '0.25'
@export_range(0, 1, 0.01) var at_percentage: float

## The icon shown at the percentage value of the event in the progress bar.
@export var icon: PackedScene


func execute(_params: Object = null) -> void:
	push_error("Called execute on the ProgressEvent base class. This does nothing.")
