describe("String", function() {

  it("truncates a string to length n", function() {
    var str = "this is a long string.";
    expect(str.trunc(5)).toEqual("this...");    
  });

  it("truncates a string to length n", function() {
    var str = "this is a long string.";
    expect(str.trunc(15)).toEqual("this is a long...");    
  });

  it("doesn't truncate string when length is less than n", function() {
    var str = "this is a long string.";
    expect(str.trunc(50)).toEqual(str);
  });

});
