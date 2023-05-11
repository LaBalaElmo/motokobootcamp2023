import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Types "types";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Array "mo:base/Array";

actor Verifier{
  stable var stableMap : [(Principal, Types.StudentProfile)] = [];
  let studentProfileStore = HashMap.fromIter<Principal,Types.StudentProfile>(stableMap.vals(), stableMap.size(), Principal.equal, Principal.hash);

  private func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : [Principal] {
    let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
    let words = Iter.toArray(Text.split(lines[1], #text(" ")));
    var i = 2;
    let controllers = Buffer.Buffer<Principal>(0);
    while (i < words.size()) {
      controllers.add(Principal.fromText(words[i]));
      i += 1;
    };
    Buffer.toArray<Principal>(controllers);
  };

  // Part 1
  public shared ({caller}) func addMyProfile(profile: Types.StudentProfile): async Result.Result<(),Text>{
    if(studentProfileStore.get(caller) == null){
      studentProfileStore.put(caller, profile);
      return #ok();
    }else{
      return #err("This account is already added");
    }
  };

  public shared query func seeAProfile(p: Principal): async Result.Result<Types.StudentProfile, Text>{
    switch(studentProfileStore.get(p)) {
      case(null) { return #err("The principal does not exist") };
      case(?profile) { return #ok(profile)};
    };
  };

  public shared ({caller}) func updateMyProfile(profile: Types.StudentProfile): async Result.Result<(),Text>{
    if(studentProfileStore.get(caller) == null){
      return #err("This account is not registered");
    }else{
      studentProfileStore.put(caller, profile);
      return #ok();
    };
  };

  public shared ({caller}) func deleteMyProfile(): async Result.Result<(),Text>{
    if(studentProfileStore.get(caller) == null){
      return #err("This account is not registered");
    }else{
      studentProfileStore.delete(caller);
      return #ok();
    };
  };

  //Part 2
  public shared func test(canisterId: Principal): async Types.TestResult{
    let calculator = actor(Principal.toText(canisterId)) : actor {
      add: (Int) -> async (Int);
      reset: () -> async (Int);
      sub: (Int) -> async (Int);
    };
    //Testing reset
    var ans: Int = 0;

    try{
      ans := await calculator.reset();
    }catch (e){
      return #err(#UnexpectedError("The function reset is not defined"));
    };

    try{
      ans := await calculator.add(1);
    }catch (e){
      return #err(#UnexpectedError("The function add is not defined"));
    };

    try{
      ans := await calculator.sub(1);
    }catch (e){
      return #err(#UnexpectedError("The function sub is not defined"));
    };

    ans := await calculator.reset();
    ans := await calculator.add(1);

    if(not (ans == 1)){
      return #err(#UnexpectedValue("The function add is not well implemented"));
    };

    ans := await calculator.reset();
    ans := await calculator.sub(1);

    if(not (ans == -1)){
      return #err(#UnexpectedValue("The function sub is not well implemented"));
    };
    
    ans := await calculator.reset();
    if(not (ans == 0)){
      return #err(#UnexpectedValue("The function reset is not well implemented"));
    };

    return #ok();
  };

  //Part 3
  public shared func verifyOwnership(canisterId: Principal, principalId: Principal): async Bool{
    try{
      let IC0 = actor("aaaaa-aa") : actor {
        canister_status : { canister_id : Principal } ->
        async {
          cycles : Nat
        };
      };
      let h = await IC0.canister_status({canister_id = canisterId});
      return false;
    }catch(e: Error){
      let controllers: [Principal] = parseControllersFromCanisterStatusErrorIfCallerNotController(Error.message(e));
      return not ((Array.find<Principal>(controllers, func(id: Principal){id == principalId})) == null)
    }
  };

  //Part 4
  public shared func verifyWork(canisterId: Principal, principalId: Principal): async Result.Result<(), Text>{
    switch(await test(canisterId)) {
      case(#ok()) { 
        if(await verifyOwnership(canisterId, principalId)){
          switch(studentProfileStore.get(principalId)) {
            case(null) { return #err("The principal does not exist"); };
            case(?studentProfile) {
              let student: Types.StudentProfile = {studentProfile with graduate = true};
              studentProfileStore.put(principalId, student);
            };
          };
          return #ok()
        }else{
          return #err("You are not the owner of the canister");
        }
      };
      case(#err(val)){
        switch(val) {
          case(#UnexpectedValue(text)) { return #err(text) };
          case(#UnexpectedError(text)) { return #err(text) };
        };
      }
    };
  };

  system func preupgrade() {
    stableMap := Iter.toArray(studentProfileStore.entries());
  };

  system func postupgrade() {
    stableMap := [];
  };
}
