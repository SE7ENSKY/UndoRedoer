UndoRedoer
==========

Simple and robust CoffeeScript/JavaScript library for undo/redo features on plain state object.
Full test coverage and it is using on production as well.

## Installation
```bash
npm install undo-redoer
```
or 
```bash
bower install undo-redoer
```

## Usage
```coffee
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

ur.canUndo() # false
ur.canRedo() # false

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


ur.canUndo() # true
ur.canRedo() # false

backDiff = ur.undo() # backDiff now contains reverse change { x:1 }

ur.canUndo() # true
ur.canRedo() # true

console.log "\nbackDiff:"
console.dir backDiff # output to console

console.log "\nstate:"
console.dir ur.state # check undo'ed state
```

above example outputs:
```

backDiff:
{ x: 1 }

state:
{ meta: { description: 'state object can be recursive as well' },
  id: 'unique-id',
  y: 2,
  x: 1 }
```

## Test
```bash
npm intall --dev
npm test
```

## Authors and contributors

 - [Se7enSky studio](http://www.se7ensky.com/)
 - [Ivan Kravchenko](http://github.com/krava)

## License

(The MIT License)

Copyright (c) 2008-2013 Se7enSky studio &lt;info@se7ensky.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
