(function() {
  Grooveshark = require('../')
  nock = require('nock');

  beforeEach(function() {
    this.addMatchers({
      toBeFunction: function() {
        return typeof this.actual === 'function'
      }
    });
  });
})();
