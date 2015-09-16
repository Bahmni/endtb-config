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
            conditions.enable.push("Baseline, How many drug-susceptible TB treatments","Baseline, Last DSTB Registration ID" )
        } else {
            conditions.disable.push("Baseline, How many drug-susceptible TB treatments","Baseline, Last DSTB Registration ID" )
        }
        return conditions; 
  },
  'Baseline, Treatment for drug-resistant TB': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Treatment for drug-resistant TB'];
        if(conditionConcept=="True") {
            conditions.enable.push("Baseline, How many drug-resistant TB treatments","Baseline, Last DRTB Registration ID")
        } else {
            conditions.disable.push("Baseline, How many drug-resistant TB treatments","Baseline, Last DRTB Registration ID")
        }
        return conditions; 
  },
  'HIV INFECTED': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['HIV INFECTED'];
        if(conditionConcept=="Positive") {
            conditions.enable.push("Date of HIV diagnosis","CD4 COUNT","Last CD4 count date","Baseline, Last RNA viral load","Baseline, Last RNA viral load date","Baseline, On ARV treatment","Antiretroviral treatment start date","Baseline, Drugs used in ARV treatment","Baseline, HIV program registration number")
        } else {
            conditions.disable.push("Date of HIV diagnosis","CD4 COUNT","Last CD4 count date","Baseline, Last RNA viral load","Baseline, Last RNA viral load date","Baseline, On ARV treatment","Antiretroviral treatment start date","Baseline, Drugs used in ARV treatment","Baseline, HIV program registration number")
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
  },
  'Baseline, WHO registration group': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, WHO registration group'];
        if(conditionConcept=="Relapse"||conditionConcept=="Treatment after loss to followup"||conditionConcept=="After failure of first treatment with first-line drugs"||conditionConcept=="After failure of retreatment regimen with first-line drugs") {
            conditions.enable.push("Baseline, History of past drug use")
        } else {
            conditions.disable.push("Baseline, History of past drug use")
        }
        return conditions;
  },
  'Baseline, MRD-TB diagnosis method': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, MRD-TB diagnosis method'];
        if(conditionConcept=="Bacteriologically Confirmed") {
            conditions.enable.push("Baseline, Method of MDR-TB confirmation")
        } else {
            conditions.disable.push("Baseline, Method of MDR-TB confirmation")
        }
        return conditions;
  },
  'Baseline, Drug resistance': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Drug resistance'];
        if(conditionConcept=="Confirmed drug resistant TB") {
            conditions.enable.push("Baseline, Subclassification for confimed drug resistant cases")
        } else {
            conditions.disable.push("Baseline, Subclassification for confimed drug resistant cases")
        }
        return conditions;
  },
  '': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues[''];
        if(conditionConcept=="") {
            conditions.enable.push("")
        } else {
            conditions.disable.push("")
        }
        return conditions;
  }   
};
