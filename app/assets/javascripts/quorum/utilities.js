//
// Truncate string to length n using word boundary.
//
String.prototype.trunc = function(n) {
  var longStr = this.length > n;
  var str     = longStr ? this.slice(0, n) : this;

  longStr ? str = str.slice(0, str.lastIndexOf(' ')) : str;

  return longStr ? str + '...' : str;
}

