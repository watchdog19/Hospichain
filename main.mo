import List "mo:base/List";
import Text "mo:base/Text";
//next of kin
actor HospitalRecordKeeper {

  var patientDatabase = List.nil<Patient>();
  var transactionDatabase = List.nil<PatientBalance>();

  type DiseaseHistory = {
    disease: Text;
    diagnosedDate: Text;
  };

  type FamilyMember = {
    id: Text;
    name: Text;
    relationship: Text;
  };

 

  type ShareConsent = {
    #Consent; 
    #Notconsent;
  };

  type Bloodtype = {
    #A;
    #B;
    #A_Negative;
    #B_Negative;
    #AB;
    #AB_Negative;
    #O;
    #O_Negative;
  };

  type Patient = {
    id: Text;
    name: Text;
    age: Nat;
    gender: Gender;
    diseaseHistory: List.List<DiseaseHistory>;
    bloodType: Bloodtype;
    familyMembers: List.List<FamilyMember>;
  };

  type Gender = {
    #Male;
    #Female;
  };
  
  type Contact = {

  };

  type PatientBalance = {
    patientId: Text;
    amount: Nat;
    date: Text;
  };

  public query func getAllPatients(): async List.List<Patient> {
    return patientDatabase;
  };

  public query func getPatient(patientId: Text): async ?Patient {
    return List.find<Patient>(patientDatabase, func(patient: Patient): Bool { patient.id == patientId });
  };

  public func addPatient(patient: Patient): async Text {
    patientDatabase := List.push<Patient>(patient, patientDatabase);
    return "Successfully added patient " # patient.name;
  };

  public func updatePatient(patientId: Text, updatedPatient: Patient): async Text {
    let updatedDatabase = List.map<Patient, Patient>(
      patientDatabase,
      func(patient: Patient): Patient {
        if (patient.id == patientId) {
          return updatedPatient;
        } else {
          return patient;
        }
      }
    );
    patientDatabase := updatedDatabase;
    return "Successfully updated patient " # updatedPatient.name;
  };

  func addFamilyMember(patientId: Text, familyMember: FamilyMember): async Text {
    let updatedDatabase = List.map<Patient, Patient>(
      patientDatabase, 
      func(patient: Patient): Patient {
        if (patient.id == patientId) {
          let updatedFamilyMembers = List.push<FamilyMember>(familyMember, patient.familyMembers);
          return { patient with familyMembers = updatedFamilyMembers };
        } else {
          return patient;
        }
      }
    );
    patientDatabase := updatedDatabase;
    return "Successfully added family member.";
  };

  public query func getFamilyMembers(patientId: Text): async List.List<FamilyMember> {
    let matchedPatient = List.find<Patient>(
      patientDatabase, 
      func(patient: Patient): Bool {
        patient.id == patientId
      }
    );

    switch(matchedPatient) {
      case(null) {
        return List.nil<FamilyMember>();
      };
      case(?foundPatient) {
        return foundPatient.familyMembers;
      };
    }
  };

  public func pay(patientId: Text, amount: Nat): async Text {
    let transaction: PatientBalance = {
      patientId = patientId;
      amount = amount; 
      date = "2024-06-01"; // Use current date in a real implementation
    };
    transactionDatabase := List.push<PatientBalance>(transaction, transactionDatabase);
    return "Transaction recorded successfully.";
  };

  public query func getTransactions(patientId: Text): async List.List<PatientBalance> {
    return List.filter<PatientBalance>(transactionDatabase, func(transaction: PatientBalance): Bool {
      transaction.patientId == patientId
    });
  };
};
