// Generated by CoffeeScript 1.6.2
/*!
 * UndoRedoer
 * @description Simple and robust CoffeeScript/JavaScript library for undo/redo features on plain state object. Full test coverage. For Node.JS and Browser (with AMD support).
 * @author Se7enSky studio <info@se7ensky.com>
 * @url http://www.se7ensky.com/
 * @version 1.2.0
 * @repository https://github.com/Se7enSky/UndoRedoer
 * @license MIT
 */
;(function(root, factory) {
  if (typeof exports === 'object') {
    return module.exports = factory(require('lodash'));
  } else if (typeof define === 'function' && define.amd) {
    return define(['lodash'], factory);
  } else {
    return root.returnExports = factory(root._);
  }
})(this, function(_) {
  var UndoRedoer;

  return UndoRedoer = (function() {
    function UndoRedoer(state, changes) {
      this.state = state != null ? state : {};
      this.changes = changes != null ? changes : [];
      this.resetCursor();
      this.reverseChanges = [];
    }

    UndoRedoer.prototype.pushChanges = function(change) {
      var reverseChange;

      this.changes.push(change);
      reverseChange = this.mergeChange(this.state, change);
      this.reverseChanges.push(reverseChange);
      return this.resetCursor();
    };

    UndoRedoer.prototype.undo = function() {
      var reverseChange;

      if (!this.canUndo()) {
        throw new Error('undo is disabled');
      }
      reverseChange = this.reverseChanges[this.cursor - 1];
      this.mergeChange(this.state, reverseChange);
      this.cursor--;
      return reverseChange;
    };

    UndoRedoer.prototype.redo = function() {
      var forwardChange;

      if (!this.canRedo()) {
        throw new Error('redo is disabled');
      }
      forwardChange = this.changes[this.cursor];
      this.mergeChange(this.state, forwardChange);
      this.cursor++;
      return forwardChange;
    };

    UndoRedoer.prototype.canUndo = function() {
      return this.cursor > 0;
    };

    UndoRedoer.prototype.canRedo = function() {
      return this.cursor < this.changes.length;
    };

    UndoRedoer.prototype.dirty = function() {
      return this.cursor < this.changes.length;
    };

    UndoRedoer.prototype.clearRedo = function() {
      return this.changes.splice(this.cursor, this.changes.length - this.cursor);
    };

    UndoRedoer.prototype.save = function() {
      return this.clearRedo();
    };

    UndoRedoer.prototype.resetCursor = function() {
      return this.cursor = this.changes.length;
    };

    /*
    		@param {Object} dst The destination object.
    		@param {Object} changes The source object.
    		@returns reverse change
    */


    UndoRedoer.prototype.mergeChange = function(dst, change) {
      var key, reverseChange, value, _ref;

      reverseChange = {};
      if (_(change).isObject() && typeof change !== 'function') {
        for (key in change) {
          value = change[key];
          if (typeof value === 'undefined') {
            if (_(dst).has(key)) {
              reverseChange[key] = dst[key];
              delete dst[key];
            } else {

            }
          } else {
            if (_(dst).has(key)) {
              if ((_ref = typeof value) === 'boolean' || _ref === 'string' || _ref === 'number') {
                reverseChange[key] = dst[key];
                dst[key] = value;
              } else if (_(value).isArray()) {
                reverseChange[key] = _(dst[key]).clone();
                dst[key] = _(value).clone();
              } else if (_(value).isObject() && typeof value !== 'function') {
                reverseChange[key] = this.mergeChange(dst[key], value);
              } else {

              }
            } else {
              reverseChange[key] = void 0;
              dst[key] = _(value).clone();
            }
          }
        }
      }
      return reverseChange;
    };

    return UndoRedoer;

  })();
});
