UndoRedoer = require './UndoRedoer'

# initiate some example state object
state =
	meta:
		description: "state object can be recursive as well"
		removeMe: "I will be removed"
	id: "unique-id"
	x: 0
	y: 0


ur = new UndoRedoer state

# push some change
ur.pushChanges
	x: 1
	y: 2

# remove something
ur.pushChanges
	meta:
		removeMe: undefined

# whoops
ur.pushChanges
	x: undefined

backDiff = ur.undo() # backDiff now contains reverse change { x:1 }

console.log "\nbackDiff:"
console.dir backDiff # output to console

console.log "\nstate:"
console.dir ur.state # check undo'ed state