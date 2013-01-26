_ = require 'lodash'

class UndoRedoer
	constructor: (@state = {}, @changes = []) ->
		@resetCursor()
		@reverseChanges = []
	pushChanges: (change) ->
		@changes.push change
		reverseChange = @mergeChange @state, change
		@reverseChanges.push reverseChange
		@resetCursor()

	undo: ->
		if @canUndo()
			reverseChange = @reverseChanges[@cursor - 1]
			@mergeChange @state, reverseChange
			@cursor--
			return reverseChange
		else
			throw new Error 'undo is disabled'
	redo: ->
		if @canRedo()
			forwardChange = @changes[@cursor]
			@mergeChange @state, forwardChange
			@cursor++
			return forwardChange
		else
			throw new Error 'redo is disabled'

	canUndo: -> @cursor > 0
	canRedo: -> @cursor < @changes.length
	dirty: -> @cursor < @changes.length

	clearRedo: -> @changes.splice @cursor, @changes.length - @cursor
	save: -> @clearRedo()

	resetCursor: -> @cursor = @changes.length

	###
	@param {Object} dst The destination object.
	@param {Object} changes The source object.
	@returns reverse change
	###
	mergeChange: (dst, change) ->
		reverseChange = {}
		if _(change).isObject() and typeof change isnt 'function'
			for key, value of change
				if typeof value is 'undefined' # delete
					if _(dst).has key
						reverseChange[key] = dst[key]
						delete dst[key]
					else
						# ignore deleting inexistent entries
				else
					if _(dst).has key
						if typeof value in ['boolean', 'string', 'number']
							reverseChange[key] = dst[key]
							dst[key] = value
						else if _(value).isArray()
							reverseChange[key] = _(dst[key]).clone()
							dst[key] = _(value).clone()
						else if _(value).isObject() and typeof value isnt 'function'
							reverseChange[key] = @mergeChange dst[key], value
						else
							# ignore incompatible objects
					else
						reverseChange[key] = undefined
						dst[key] = _(value).clone()
		return reverseChange

module.exports = UndoRedoer
