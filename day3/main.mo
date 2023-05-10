import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Order "mo:base/Order";

actor StudentWall{

  public type Content = {
    #Text: Text;
    #Image: Blob;
    #Video: Blob;
  };

  public type Message = {
    vote: Int;
    content: Content;
    creator: Principal
  };

  var messageId: Nat = 0;
  var wall = HashMap.HashMap<Nat, Message>(1, Nat.equal, Hash.hash);
  let defaultMessage: Message = {
    vote = 0;
    content = #Text("");
    creator = Principal.fromActor(actor "ngcjg-3bfou-newsj-kwimw-3fwmj-s2qmu-au2a3-75pso-e3ndi-alrwo-hqe");
  };

  // Add a new message to the wall
  public shared ({caller}) func writeMessage(c : Content): async Nat{
    let message: Message = {
      vote = 0;
      content = c;
      creator = caller;
    };
    let id: Nat = messageId;
    messageId += 1;
    wall.put(id, message);
    return id;
  };

  //Get a specific message by ID
  public shared query func getMessage(messageId : Nat): async Result.Result<Message, Text>{
    if(wall.get(messageId) == null){
      #err("The message ID value is not valid");
    }else{
      #ok(switch (wall.get(messageId)) {
        case (null) { defaultMessage };
        case (?n) { n };
      });
    };
  };

  // Update the content for a specific message by ID
  public shared ({caller}) func updateMessage(messageId : Nat, c : Content): async Result.Result<(), Text>{
    if(wall.get(messageId) == null){
      #err("The message ID value is not valid");
    }else{
      switch (wall.get(messageId)) {
        case (null) { #err("The message ID value is not valid") };
        case (?n) { 
          let message = {n with content = c};
          if(message.creator != caller){
            #err("The caller is not the creator");
          }else{
            wall.put(messageId, message);
            #ok();
          };
        };
      };
    };
  };

  //Delete a specific message by ID
  public shared func deleteMessage(messageId : Nat): async Result.Result<(), Text>{
    if(wall.get(messageId) == null){
      #err("The message ID value is not valid");
    }else{
      switch (wall.get(messageId)) {
        case (null) { #err("The message ID value is not valid") };
        case (?n) { 
          wall.delete(messageId);
          #ok()
        };
      };
    };
  };

  // Voting
  public shared func upVote(messageId  : Nat): async Result.Result<(), Text>{
    if(wall.get(messageId) == null){
      #err("The message ID value is not valid");
    }else{
      switch (wall.get(messageId)) {
        case (null) { #err("The message ID value is not valid") };
        case (?n) { 
          let message = {n with vote = n.vote + 1};
          wall.put(messageId, message);
          #ok()
        };
      };
    };
  };

  public shared func downVote(messageId  : Nat): async Result.Result<(), Text>{
    if(wall.get(messageId) == null){
      #err("The message ID value is not valid");
    }else{
      switch (wall.get(messageId)) {
        case (null) { #err("The message ID value is not valid") };
        case (?n) { 
          let message = {n with vote = n.vote - 1};
          wall.put(messageId, message);
          #ok()
        };
      };
    };
  };

  //Get all messages
  public query func getAllMessages(): async [Message]{
    return Iter.toArray(wall.vals());
  };

  private func compare(x : Message, y : Message) : Order.Order {
    if (x.vote > y.vote) { #less } else if (x.vote == y.vote) { #equal } else { #greater }
  };

  //Get all messages
  public query func getAllMessagesRanked(): async [Message]{
    let allMessage = Iter.sort<Message>(wall.vals(), compare);
    return Iter.toArray(allMessage);
  };
};