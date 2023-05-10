import Time "mo:base/Time";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Text "mo:base/Text";

actor HomeworkDiary{
  type Pattern = Text.Pattern;
  public type Time = Time.Time;
  type Homework = {
    title: Text;
    description: Text;
    dueDate: Time;
    completed: Bool;
  };

  private let defaultHomework: Homework = {title = "null"; description = "null"; dueDate = Time.now(); completed = true };

  let homeworkDiary: [var Homework] = Array.init(100000, defaultHomework);

  // Add a new homework task
  public shared func addHomework(homework: Homework): async Nat{
    var cont: Nat = 0;
    for(hmd in homeworkDiary.vals()){
      if(hmd.title == "null"){
        homeworkDiary[cont] := homework;
        return cont;
      };
      cont += 1;
    };
    return 100001;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id: Nat): async Result.Result<Homework, Text>{
    if(homeworkDiary[id].title == "null"){
      #err("The homework id is not valid");
    }else{
      #ok(homeworkDiary[id]);
    };
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id: Nat, homework: Homework): async Result.Result<(), Text>{
    if(homeworkDiary[id].title == "null"){
      #err("The homework id is not valid");
    }else{
      homeworkDiary[id] := homework;
      #ok()
    };
  };

  // Mark a homework task as completed 
  public shared func markAsCompleted(id: Nat): async Result.Result<(), Text>{
    if(homeworkDiary[id].title == "null"){
      #err("The homework id is not valid");
    }else{
      let hwd = {homeworkDiary[id] with completed=true};
      homeworkDiary[id] := hwd;
      #ok()
    };
  };

  // Delete a homework task by id
  public shared func deleteHomework(id: Nat): async Result.Result<(), Text>{
    if(homeworkDiary[id].title == "null"){
      #err("The homework id is not valid");
    }else{
      homeworkDiary[id] := defaultHomework;
      #ok()
    };
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework(): async [Homework]{
    return Array.filter<Homework>(Array.freeze(homeworkDiary), func(homework: Homework){homework.title != "null"})
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework(): async [Homework]{
    return Array.filter<Homework>(Array.freeze(homeworkDiary), func(homework: Homework){homework.completed == false})
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm: Text): async [Homework]{
    let term: Pattern = #text(searchTerm);
    return Array.filter<Homework>(Array.freeze(homeworkDiary), func(homework: Homework){Text.contains(homework.title, term)});
  }
}
