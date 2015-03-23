module.exports = FantasyPromise;

function FantasyPromise(promise) {
  this.promise = promise;
}

FantasyPromise.prototype.chain =
FantasyPromise.prototype.map = function(f) {
  return new FantasyPromise(this.promise.then(f));
};

FantasyPromise.prototype.then = function(handler, errfn) {
  return new FantasyPromise(this.promise.then(handler, errfn));
};

FantasyPromise.prototype.catch = function(errfn) {
  return new FantasyPromise(this.promise.catch(errfn));
};

FantasyPromise.prototype.ap = function(b) {
  return this.map(b.map.bind(b));
};

FantasyPromise.of = function(p) {
  return new FantasyPromise(p);
};
