import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

actor MotokoCoin{
  type Subaccount = Blob;

  type Account = {
    owner : Principal;
    subaccount : ?Subaccount;
  };

  private func isEq(k1: Account, k2: Account): Bool{
    return k1.owner == k2.owner;
  }; 

  private func hashOf(k: Account): Nat32{
    return Principal.hash(k.owner);
  }; 

  var ledger = TrieMap.TrieMap<Account, Nat>(isEq, hashOf);
  private var totalTokens: Nat = 0;

  // Returns the name of the token 
  public shared query func name (): async Text{
    return "MotoCoin";
  };

  // Returns the symbol of the token 
  public shared query func symbol(): async Text{
    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public shared query func totalSupply(): async Nat{
    return totalTokens;
  };

  // Returns the balance of the account
  public shared query func balanceOf(account : Account): async (Nat){
    switch (ledger.get(account)) {
      case (null) { return 0; };
      case (?balance) { 
        return balance;
      };
    };
  };

  // Transfer tokens to another account
  public shared func transfer(from: Account, to : Account, amount : Nat): async Result.Result<(), Text>{
    switch (ledger.get(from)) {
      case (null) {
        return #err("The sender account does not exist");
      };
      case (?balanceFrom) { 
        if(balanceFrom < amount){
          #err("The sender account does not have enough supply");
        }else{
          switch(ledger.get(to)) {
            case(null) {
              #err("The destination account does not exist");
            };
            case(?balanceTo) {
              ledger.put(from, balanceFrom - amount);
              ledger.put(to, balanceTo + amount);
              #ok()
            };
          };
        };
      };
    };
  };

  // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
  public shared func airdrop(): async Result.Result<(),Text>{
    let motokoCanister = actor("rww3b-zqaaa-aaaam-abioa-cai") : actor {
      getAllStudentsPrincipal : shared () -> async [Principal];
    };
    let studentsPrincipal: [Principal] = await motokoCanister.getAllStudentsPrincipal();
    let amountToAirDrop: Nat = 100;
    for(principal in studentsPrincipal.vals()){
      let key: Account = {owner = principal; subaccount=null};
      try{
        switch(ledger.get(key)) {
          case(null) {
            ledger.put(key, amountToAirDrop);
            totalTokens += amountToAirDrop;
          };
          case(?balance) {
            ledger.put(key, balance + amountToAirDrop);
            totalTokens += amountToAirDrop;
          };
        };
      }catch (e){
        return #err("");
      };
    };
    #ok();
  };
}