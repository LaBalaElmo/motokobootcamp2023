import Float "mo:base/Float";

actor Calculator {

  var counter: Float = 0;

  public func add(x : Float) : async Float {
    counter += x;
    return counter;
  };

  public func sub(x : Float) : async Float {
    counter -= x;
    return counter;
  };

  public func mul(x : Float) : async Float {
    counter *= x;
    return counter;
  };

  public func div(x : Float) : async ?Float {
    if(x == 0){
      return null;
    };
    counter /= x;
    return ?counter;
  };

  public func reset() : async () {
    counter := 0;
  };

  public query func see() : async Float {
    return counter;
  };

  public func power(x : Float) : async Float {
    counter := counter ** x;
    return counter;
  };

  public func sqrt() : async Float {
    counter := Float.sqrt(counter);
    return counter;
  };

  public func floor() : async Float {
    counter := Float.floor(counter);
    return counter;
  };

};
