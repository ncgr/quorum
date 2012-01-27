//
// Truncate string to length n using word boundary.
//
String.prototype.trunc = function(n) {
  var longStr = this.length > n;
  var str     = longStr ? this.substr(0, n-1) : this;

  longStr ? str.substr(0, str.lastIndexOf(' ')) : str;
  return longStr ? str + '...' : str;
}

