_ = require 'lodash'

describe 'UndoRedoer', ->

	UndoRedoer = null

	it 'should exist', ->
		UndoRedoer = require './UndoRedoer'
		UndoRedoer.should.not.eql.null

	requiredMethods = ['pushChanges', 'canUndo', 'canRedo', 'undo', 'redo', 'dirty', 'save']
	it "should have methods: #{requiredMethods.join ', '}", ->
		for methodName in requiredMethods
			UndoRedoer.prototype.should.have.property(methodName).and.should.be.function

	describe '#constructor', ->
		it 'should accept and store @state', ->
			exampleState = { 'I': 'am', 'state': 'field' }
			o = new UndoRedoer exampleState
			o.should.have.property('state').and.should.not.be.empty
			o.state.should.eql exampleState
		it 'should accept empty state', ->
			o = new UndoRedoer
			o.state.should.eql {}
	
	describe '#pushChanges', ->
		it 'should accept and store simple changes maintaining state', ->
			o = new UndoRedoer
			o.pushChanges { a:0, b:0 }
			o.state.should.eql { a:0, b:0 }
			o.pushChanges { a:1 }
			o.state.should.eql { a:1, b:0 }
			o.changes.should.eql [
				{ a:0, b:0 }
				{ a:1 }
			]
		it 'should accept and store recursive changes maintaining @state', ->
			o = new UndoRedoer
			o.pushChanges { flat:0, recursive:{ a:0, b:0 } }
			o.state.should.eql { flat:0, recursive:{ a:0, b:0 } }
			o.pushChanges { a:1 }
			o.state.should.eql { a:1, flat:0, recursive:{ a:0, b:0 } }
			o.pushChanges { recursive: { b:1 } } # deep incremental change
			o.state.should.eql { a:1, flat:0, recursive:{ a:0, b:1 } }
			o.pushChanges { recursive: { innerRecursive:[1, 2, {a:"b"}] } } # deep incremental change
			o.state.should.eql { a:1, flat:0, recursive:{ a:0, b:1, innerRecursive:[1, 2, {a:"b"}] } }
			o.changes.should.eql [
				{ flat:0, recursive:{ a:0, b:0 } }
				{ a:1 }
				{ recursive: { b:1 } }
				{ recursive: { innerRecursive:[1, 2, {a:"b"}] } }
			]

	describe '@cursor', ->
		it 'should be 0 at start and reset after #pushChanges', ->
			o = new UndoRedoer
			o.cursor.should.eql 0
			o.pushChanges {}
			o.cursor.should.eql 1
			o.pushChanges {}
			o.cursor.should.eql 2
		it 'should shift left on #undo and right on #redo, throwing Error on #undo/#redo not available', ->
			o = new UndoRedoer
			undoCheck = (u, r) ->
				o.undo()
				o.cursor.should.eql u
			redoCheck = (u, r) ->
				o.redo()
				o.cursor.should.eql u
			o.pushChanges {}
			o.pushChanges {}
			o.pushChanges {}
			o.pushChanges {}
			o.pushChanges {}
			o.dirty().should.be.false
			o.redo.should.throw()
			undoCheck 4
			undoCheck 3
			undoCheck 2
			undoCheck 1
			undoCheck 0
			o.undo.should.throw()
			redoCheck 1
			redoCheck 2
			redoCheck 3
			redoCheck 4
			redoCheck 5
			o.redo.should.throw()

	describe '#undo', ->
		it 'should undo state and return backdiff', ->
			o = new UndoRedoer
			o.pushChanges { a:1 }
			o.pushChanges { b:2 }
			o.pushChanges { a:2 }
			o.pushChanges { b:[1,2,3] }
			o.state.should.eql { a:2, b:[1,2,3] }

			o.undo().should.eql { b:2 }
			o.state.should.eql { a:2, b:2 }
			o.undo().should.eql { a:1 }
			o.state.should.eql { a:1, b:2 }
			o.undo().should.eql { b:undefined }
			o.state.should.eql { a:1 }
			o.undo().should.eql { a:undefined }
			o.state.should.eql { }

	describe '#redo', ->
		it 'should redo state and return changes', ->
			o = new UndoRedoer
			o.pushChanges { a:1 }
			o.pushChanges { b:2 }
			o.pushChanges { a:2 }
			o.pushChanges { b:[1,2,3] }
			_(4).times -> o.undo()

			o.redo().should.eql { a:1 }
			o.state.should.eql { a:1 }
			o.redo().should.eql { b:2 }
			o.state.should.eql { a:1, b:2 }
			o.redo().should.eql { a:2 }
			o.state.should.eql { a:2, b:2 }
			o.redo().should.eql { b:[1,2,3] }
			o.state.should.eql { a:2, b:[1,2,3] }

	describe '#undo/#redo', ->
		it 'should work in both directions', ->
			o = new UndoRedoer
			o.pushChanges { a:1 }
			o.pushChanges { b:2 }
			o.pushChanges { a:2 }
			o.pushChanges { b:[1,2,3] }

			o.undo()
			o.undo()
			o.state.should.eql { a:1, b:2 }
			o.redo()
			o.state.should.eql { a:2, b:2 }
			o.redo()
			o.state.should.eql { a:2, b:[1,2,3] }
			_(4).times -> o.undo()
			o.state.should.eql { }
			_(4).times -> o.redo()
			o.state.should.eql { a:2, b:[1,2,3] }

	describe '#dirty/#save', ->
		it 'should clear redo', ->
			o = new UndoRedoer
			o.pushChanges { a:1 }
			o.pushChanges { b:2 }
			o.pushChanges { a:2 }
			o.pushChanges { b:[1,2,3] }

			o.dirty().should.be.false

			o.undo()
			o.dirty().should.be.true
			o.undo()
			o.dirty().should.be.true

			o.save()
			o.dirty().should.be.false
			o.redo.should.throw()

			o.undo()
			o.state.should.eql { a:1 }
			o.dirty().should.be.true

			o.redo()
			o.state.should.eql { a:1, b:2 }
			o.dirty().should.be.false


	describe '#mergeChange', ->
		it 'merge as usual and return reverse change', ->
			o = new UndoRedoer
			
			state1 = { a:{f1:0, f2:1}, b:{ r:0 }, toDelete:5 }
			diff = { b:{ r:[1, 2], newField:[1, 2, 3] }, a:{f1:2}, toDelete:undefined }
			state2 = { a:{f1:2, f2:1}, b:{ r:[1, 2], newField:[1, 2, 3] } }
			backdiff = { b:{ r:0, newField:undefined }, a:{f1:0}, toDelete:5 }
			
			resultState = _(state1).clone()
			resultBackdiff = o.mergeChange resultState, diff
			resultState.should.eql state2
			resultBackdiff.should.eql backdiff
