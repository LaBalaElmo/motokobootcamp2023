import Float "mo:base/Float";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Option "mo:base/Option";

actor Calculator {
  public query func add(x : Float, y: Float) : async Float {
    return x+y;
  };

  public query func sub(x : Float, y: Float) : async Float {
    return x-y;
  };

  public query func mul(x : Float, y: Float) : async Float {
    return x*y;
  };

  public query func div(x : Float, y: Float) : async Float {
    return x/y;
  };

  public query func power(x : Float, toPow: Float) : async Float {
    return x ** toPow;
  };

  public query func sqrt(x: Float) : async Float {
    return Float.sqrt(x);
  };

  public query func generalOperation(operation: [Float]): async Float {
    var ans: Float = 0;
    for(i in operation.vals()){
      if(ans != 0){
        ans += i;
      }else{
        ans := i;
      };
    };
    return ans;
  }

};
