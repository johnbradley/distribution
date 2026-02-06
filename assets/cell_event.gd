class_name CellEvent
extends Resource

# Details about a spawn/sink event - part of leve setup

@export var time: float                 # When this event occurs
@export var region: GridCell.Direction  # Which side of the grid we are selecting a cell from
@export var index: int                  # Index into the array of cells on our side of the grid 
@export var color: GridCell.CellColor   # Color of the spawn/sink cell
@export var lifespan: float             # When to cleanup this cell
@export var count: int                  # How many boxes to spawn - spawn cell only

func execute():
    pass  # Override in child classes


