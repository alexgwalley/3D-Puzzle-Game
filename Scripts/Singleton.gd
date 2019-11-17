extends Node

const BUILD_MODE = 0
const WIRE_MODE = 1
const INTERACT_MODE = 2
const CHECKING_MODE = 3

var gameMode = 0

var gateMode = 0
var numberOfGates = 4

# 0 means computer
# 1 means joystick
const COMPUTER_MODE = 0
const JOYSTICK_MODE = 1
var inputMode = 0

onready var input_pos = get_viewport().size/2
onready var desired_input_pos = get_viewport().size/2

var current_puzzle

const OR_GATE_TYPE  = 0
const AND_GATE_TYPE = 1
const NOT_GATE_TYPE = 2
const XOR_GATE_TYPE = 3

const PLAY_MODE = 0
const MAP_MODE = -1

var camera_mode = PLAY_MODE


