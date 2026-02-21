extends Node

const GRID_SIZE: int = 7
const CELL_SIZE: int = 128
const CELL_OFFSET: int = 64 + 64 # Half cell size plus offset for box slides 
const DOWNTIME_UPDATE_INCREMENT: float = 0.2

const WAIT_BEFORE_FIRST_MOVE: float = 0.3
const WAIT_BETWEEN_MOVES: float = 0.4
const WAIT_AFTER_SEND_INDICATOR: float = 0.1
const MOVE_TIME_MULTIPLIER: float =  5.0
const STARTING_TIME_JUMP: float = 0.1
const CLOSE_ENOUGH_SQUARED: int = 100

const FIRST_SPAWN_WAIT: float = 1.0
const SUBSEQUENT_SPAWN_WAIT: float = 4.0
const CLEANUP_WAIT: float = 2.0
