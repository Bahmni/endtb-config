Bahmni.ConceptSet.FormConditions.rules = {      //This is a constant that Bahmni expects
  'Baseline, Is alcoholic': function(formName, formFieldValues) {//'Chief Complaint Data' concept when edited, triggers this function
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Is alcoholic'];
        if(conditionConcept=="True") {
            conditions.enable.push("Baseline, How many alcoholic drinks per week")
        } else {
            conditions.disable.push("Baseline, How many alcoholic drinks per week")
        }
        return conditions; //Return object SHOULD be a map with 'enable' and 'disable' arrays having the concept names
  },
  'Baseline, Treatment for drug-susceptible TB': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Treatment for drug-susceptible TB'];
        if(conditionConcept=="True") {
            conditions.enable.push("Baseline, How many drug-susceptible TB treatments")
        } else {
            conditions.disable.push("Baseline, How many drug-susceptible TB treatments")
        }
        return conditions; 
  },
  'Baseline, Treatment for drug-resistant TB': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Treatment for drug-resistant TB'];
        if(conditionConcept=="True") {
            conditions.enable.push("Baseline, How many drug-resistant TB treatments")
        } else {
            conditions.disable.push("Baseline, How many drug-resistant TB treatments")
        }
        return conditions; 
  },
  'HIV INFECTED': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['HIV INFECTED'];
        if(conditionConcept=="Positive") {
            conditions.enable.push("Date of HIV diagnosis","CD4 COUNT","Last CD4 count date","Baseline, Last RNA viral load","Baseline, Last RNA viral load date","Baseline, On ARV treatment","Antiretroviral treatment start date","Baseline, Drugs used in ARV treatment")
        } else {
            conditions.disable.push("Date of HIV diagnosis","CD4 COUNT","Last CD4 count date","Baseline, Last RNA viral load","Baseline, Last RNA viral load date","Baseline, On ARV treatment","Antiretroviral treatment start date","Baseline, Drugs used in ARV treatment")
        }
        return conditions;
  },
  'Diabetes Mellitus': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Diabetes Mellitus'];
        if(conditionConcept=="True") {
            conditions.enable.push("glycosylated hemoglobin A measurement")
        } else {
            conditions.disable.push("glycosylated hemoglobin A measurement")
        }
        return conditions;
  },
  'Baseline, Has cancer': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Has cancer'];
        if(conditionConcept=="True") {
            conditions.enable.push("Baseline, Cancer type")
        } else {
            conditions.disable.push("Baseline, Cancer type")
        }
        return conditions;
  },
  'Baseline, Has other psychiatric illness': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Has other psychiatric illness'];
        if(conditionConcept=="True") {
            conditions.enable.push("Baseline, Psychiatric illness type")
        } else {
            conditions.disable.push("Baseline, Psychiatric illness type")
        }
        return conditions;
  },
  'Baseline, Currently pregnant': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Currently pregnant'];
        if(conditionConcept=="True") {
            conditions.enable.push("Estimated date of confinement")
        } else {
            conditions.disable.push("Estimated date of confinement")
        }
        return conditions;
  },
  'Baseline, Did the patient start treatment': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Did the patient start treatment'];
	if(conditionConcept == false) {
            conditions.enable.push("Baseline, Reason for not starting treatment")
        } else {
            conditions.disable.push("Baseline, Reason for not starting treatment")
        }
        return conditions;
  },
  'Followup, New serious AE reported': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Followup, New serious AE reported'];
        if(conditionConcept) {
            conditions.enable.push("Followup, New serious AE reference number")
        } else {
            conditions.disable.push("Followup, New serious AE reference number")
        }
        return conditions;
  },
  'Followup, New AE reported': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Followup, New AE reported'];
        if(conditionConcept) {
            conditions.enable.push("Followup, New AE reference number")
        } else {
            conditions.disable.push("Followup, New AE reference number")
        }
        return conditions;
  },
  'Medication log, Drug end date': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Medication log, Drug end date'];
        if(conditionConcept) {
            conditions.enable.push("Medication log, Reason for medication change")
        } else {
            conditions.disable.push("Medication log, Reason for medication change")
        }
        return conditions;
  },
  'Medication log, Reason for medication change': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Medication log, Reason for medication change'];
        if(conditionConcept=="Other") {
            conditions.enable.push("Medication log, Other reason for medication change")
        } else {
            conditions.disable.push("Medication log, Other reason for medication change")
        }
        return conditions;
  }   
};
