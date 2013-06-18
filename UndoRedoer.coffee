`/*!
 * UndoRedoer
 * @description Simple and robust CoffeeScript/JavaScript library for undo/redo features on plain state object. Full test coverage. For Node.JS and Browser (with AMD support).
 * @author Se7enSky studio <info@se7ensky.com>
 * @url http://www.se7ensky.com/
 * @version 1.2.2
 * @repository https://github.com/Se7enSky/UndoRedoer
 * @license MIT
 */
`

((root, factory) ->
	if typeof exports is 'object'
		module.exports = factory require 'lodash'
	else if typeof define is 'function' and define.amd
		define ['lodash'], factory
	else
		root.returnExports = factory root._
) @, (_) ->
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
			throw new Error 'undo is disabled' if not @canUndo()
			reverseChange = @reverseChanges[@cursor - 1]
			@mergeChange @state, reverseChange
			@cursor--
			reverseChange
				
		redo: ->
			throw new Error 'redo is disabled' if not @canRedo()
			forwardChange = @changes[@cursor]
			@mergeChange @state, forwardChange
			@cursor++
			return forwardChange

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
