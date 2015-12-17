Bahmni.ConceptSet.FormConditions.rules = {      //This is a constant that Bahmni expects
  'Baseline, Employment within the past year': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Employment within the past year'];
        if(conditionConcept=="Other") {
            conditions.enable.push("Baseline, Other employment")
        } else {
            conditions.disable.push("Baseline, Other employment")
        }
        return conditions; 
  },
  'Baseline, Prison': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Prison'];
        if(conditionConcept=="True") {
            conditions.enable.push("Baseline, Is prison past or present")
        } else {
            conditions.disable.push("Baseline, Is prison past or present")
        }
        return conditions;   
  },
  'Baseline, Is alcoholic': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Is alcoholic'];
        if(conditionConcept=="True") {
            conditions.enable.push("Baseline, How many alcoholic drinks per week")
        } else {
            conditions.disable.push("Baseline, How many alcoholic drinks per week")
        }
        return conditions; 
  },
  'Baseline, Treatment for drug-susceptible TB': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Treatment for drug-susceptible TB'];
        if(conditionConcept=="True") {
            conditions.enable.push("Baseline, How many drug-susceptible TB treatments","Baseline, Last DSTB Registration ID","Baseline, Last DSTB treatment registration facility")
        } else {
            conditions.disable.push("Baseline, How many drug-susceptible TB treatments","Baseline, Last DSTB Registration ID","Baseline, Last DSTB treatment registration facility")
        }
        return conditions; 
  },
  'Baseline, Treatment for drug-resistant TB': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Treatment for drug-resistant TB'];
        if(conditionConcept=="True") {
            conditions.enable.push("Baseline, How many drug-resistant TB treatments","Baseline, Last DRTB Registration ID","Baseline, Last DRTB treatment registration facility")
        } else {
            conditions.disable.push("Baseline, How many drug-resistant TB treatments","Baseline, Last DRTB Registration ID","Baseline, Last DRTB treatment registration facility")
        }
        return conditions; 
  },
  'Baseline, HIV serostatus result' : function (formName, formFieldValues) {
	var conditions = {
		enable : [],
		disable : []
	};
	var conditionConcept = formFieldValues['Baseline, HIV serostatus result'];
	if (conditionConcept == "Positive") {
		conditions.enable.push("Baseline, HIV program registration number", "Date of HIV diagnosis", "CD4 COUNT", "CD4 date", "HIV VIRAL LOAD", "Baseline, Last RNA viral load date", "Baseline, On ARV treatment")
	} else {
		conditions.disable.push("Baseline, HIV program registration number", "Date of HIV diagnosis", "CD4 COUNT", "CD4 date", "HIV VIRAL LOAD", "Baseline, Last RNA viral load date", "Baseline, On ARV treatment")
	}
	return conditions;
  },
  'Baseline, On ARV treatment': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, On ARV treatment'];
        if(conditionConcept=="True") {
            conditions.enable.push("Antiretroviral treatment start date","Baseline, Drugs used in ARV treatment")
        } else {
            conditions.disable.push("Antiretroviral treatment start date","Baseline, Drugs used in ARV treatment")
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
  'Baseline, Heart or atherosclerotic disease' : function (formName, formFieldValues) {
	var conditions = {
		enable : [],
		disable : []
	};
	var conditionConcept = formFieldValues['Baseline, Heart or atherosclerotic disease'];
	if (conditionConcept == "True") {
		conditions.enable.push("Baseline, Type of heart disease")
	} else {
		conditions.disable.push("Baseline, Type of heart disease")
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
  'Baseline, Pre-existing neuropathy' : function (formName, formFieldValues) {
	var conditions = {
		enable : [],
		disable : []
	};
	var conditionConcept = formFieldValues['Baseline, Pre-existing neuropathy'];
	if (conditionConcept == "True") {
		conditions.enable.push("Baseline, Neuropathy grade")
	} else {
		conditions.disable.push("Baseline, Neuropathy grade")
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
  'Baseline, WHO registration group': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, WHO registration group'];
        if(conditionConcept=="Relapse"||conditionConcept=="Treatment after loss to followup"||conditionConcept=="Treatment After Failure to Drugs"||conditionConcept=="Other previously treated patients") {
            conditions.enable.push("Category IV tuberculosis classification")
        } else {
            conditions.disable.push("Category IV tuberculosis classification")
        }
        return conditions;
  },
  'Baseline, Disease site' : function (formName, formFieldValues) {
	var conditions = {
		enable : [],
		disable : []
	};
	var enExtraPul = "Baseline, Exact extrapulmonary site";
	var conditionConcept = formFieldValues['Baseline, Disease site'];
	if (conditionConcept == "Extrapulmonary") {
		conditions.enable.push(enExtraPul);
	} else {
		conditions.disable.push(enExtraPul);
	}
	return conditions;
  },
  'Baseline, MRD-TB diagnosis method' : function (formName, formFieldValues) {
	var conditions = {
		enable : [],
		disable : []
	};
	var conditionConcept = formFieldValues['Baseline, MRD-TB diagnosis method'];
	if (conditionConcept == "Bacteriologically Confirmed") {
		conditions.enable.push("Baseline, Method of MDR-TB confirmation");
		var enMethod = formFieldValues['Baseline, Method of MDR-TB confirmation'];
		if (enMethod != null) {
			if (enMethod.indexOf("Other") > -1) {
				conditions.enable.push("Baseline, Other method of MDR-TB confirmation");
			} else {
				conditions.disable.push("Baseline, Other method of MDR-TB confirmation");
			}
		} else {
			conditions.disable.push("Baseline, Other method of MDR-TB confirmation");
		}
	} else {
		conditions.disable.push("Baseline, Method of MDR-TB confirmation", "Baseline, Other method of MDR-TB confirmation")
	}
	return conditions;
  },
  'Baseline, Method of MDR-TB confirmation' : function (formName, formFieldValues) {
	var conditions = {
		enable : [],
		disable : []
	};
	var conditionConcept = formFieldValues['Baseline, Method of MDR-TB confirmation'];
	if (conditionConcept != null) 
	{
		if (conditionConcept.indexOf("Other") > -1) 
		{
			conditions.enable.push("Baseline, Other method of MDR-TB confirmation")
		} 
		else 
		{			
			conditions.disable.push("Baseline, Other method of MDR-TB confirmation")
		}
	} 
	else 
	{
		conditions.disable.push("Baseline, Other method of MDR-TB confirmation")
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
  'Baseline, Eligible for new drugs' : function (formName, formFieldValues) {
	var conditions = {
		enable : [],
		disable : []
	};
	var enDate = "Baseline, Date of eligibility for new drugs";
	var en4Drugs = "Baseline, Patients for whom the construction of a regimen with four likely effective second-line drugs is not possible";
	var enUnfavourable = "Baseline, Other patients who have high risk of unfavorable outcome but who do not fit the above categories";
	var result = formFieldValues['Baseline, Eligible for new drugs'];
	if (result == "True") {
		conditions.enable.push(enDate,en4Drugs,enUnfavourable);
	} else {
		conditions.disable.push(enDate,en4Drugs,enUnfavourable);
	}
	return conditions;
  },
    'Baseline, Did the patient start treatment' : function (formName, formFieldValues) {
        var enReason = "Baseline, Reason for not starting treatment";
        var conditionConcept = formFieldValues['Baseline, Did the patient start treatment'];
        if(conditionConcept == false) {
            return {enable: [enReason]}
        } else {
            return {disable: [enReason]}
        }
    },
    'Baseline, Reason for not starting treatment': function(formName, formFieldValues) {
        var conditionConcept = formFieldValues['Baseline, Reason for not starting treatment'];
        var deathDT = "Baseline, date of death before treatment start";

        if(conditionConcept == "Died") {
            return {enable: [deathDT]}
        } else {
            return {disable: [deathDT]}
        }
    },
    'Drug Allergies' : function (formName, formFieldValues) {
        var conditions = {
            enable : [],
            disable : []
        };
        var conditionConcept = formFieldValues['Drug Allergies'];
        if (conditionConcept == "True") {
            conditions.enable.push("Which Drug Allergies")
        } else {
            conditions.disable.push("Which Drug Allergies")
        }
        return conditions;
    },
  'Medication log, Type of treatment regimen': function (formName, formFieldValues) {
        var conceptToEnable_firstLine = "Medication log, First line drug regimen type";
        var conceptToEnable_secondLine = "Medication log, Second line regimen drug type"; 
        var conditions = {enable: [], disable: []};	
	var conditionConcept = formFieldValues['Medication log, Type of treatment regimen'];    
	if(conditionConcept == "Only 1st line drugs" ) {
		conditions.enable.push(conceptToEnable_firstLine)
	} else {
		conditions.disable.push(conceptToEnable_firstLine)
	}
	if(conditionConcept == "Regimen including 2nd line drugs" ) {
		conditions.enable.push(conceptToEnable_secondLine)
	} else {
		conditions.disable.push(conceptToEnable_secondLine)
	}
        return conditions;
  },
  'Medication log, Treatment delivery method': function causeOfDeathLogics(formName, formFieldValues) {
        var conceptToEnable = "Medication log, Other treatment delivery method";
        var conditions = {enable: [], disable: []}	
	var conditionConcept = formFieldValues['Medication log, Treatment delivery method'];    	
	if(conditionConcept == "Other" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}		
        return conditions;
  },
  'Medication log, Drug stop date': function(formName, formFieldValues) {
	var conceptToEnable = "Medication log, Reason for medication change";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Medication log, Drug stop date'];
        var conceptToEnable_AE = "Medication log, AE ID number";
        var conceptToEnable_other = "Medication log, Other reason for medication change";
        if(conditionConcept) {
		conditions.enable.push(conceptToEnable);
		var reason = formFieldValues['Medication log, Reason for medication change'];    
		if(reason == "Adverse event" ) {
			conditions.enable.push(conceptToEnable_AE)
		} else {
			conditions.disable.push(conceptToEnable_AE)
		}		
		if(reason == "Other" ) {
			conditions.enable.push(conceptToEnable_other)
		} else {
			conditions.disable.push(conceptToEnable_other)
		}
        } else {
            conditions.disable.push(conceptToEnable, conceptToEnable_AE, conceptToEnable_other)
        }
        return conditions;
  },
  'Medication log, Reason for medication change': function (formName, formFieldValues) {
        var conceptToEnable_AE = "Medication log, AE ID number";
        var conceptToEnable_other = "Medication log, Other reason for medication change";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Medication log, Reason for medication change'];    
	if(conditionConcept == "Adverse event" ) {
		conditions.enable.push(conceptToEnable_AE)
	} else {
		conditions.disable.push(conceptToEnable_AE)
	}
	if(conditionConcept == "Other" ) {
		conditions.enable.push(conceptToEnable_other)
	} else {
		conditions.disable.push(conceptToEnable_other)
	}      
	return conditions;
  },
  'Followup, Type of Visit': function (formName, formFieldValues) {
        var conceptToEnable = "Followup, Month of scheduled visit";
        var conditions = {enable: [], disable: []};		
	var conditionConcept = formFieldValues['Followup, Type of Visit'];    
	if(conditionConcept == "Scheduled monthly visit" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
        return conditions; 
  },
  'Followup, Currently Pregnant': function (formName, formFieldValues) {
        var conceptToEnable = "Followup, Pregnancy form case ID number";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Followup, Currently Pregnant'];    
	if(conditionConcept == "True" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}	    
        return conditions; 
  },
  'Followup, Is alcoholic': function (formName, formFieldValues) {
        var conceptToEnable = "Followup, How many alcoholic drinks per week";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Followup, Is alcoholic'];
        if(conditionConcept == "True" ) {
                conditions.enable.push(conceptToEnable)
        } else {
                conditions.disable.push(conceptToEnable)
        }           
        return conditions;   
  },
  'Followup, New serious AE reported': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Followup, New serious AE reported'];
	var conceptToEnable = "Followup, New serious AE reference number";
        if(conditionConcept) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
  },
  'Followup, New AE reported': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Followup, New AE reported'];
        var conceptToEnable = "Followup, New AE reference number";
        if(conditionConcept) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
  },
  'Followup, Admitted into a hospital for any reason': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Followup, Admitted into a hospital for any reason'];
        var conceptToEnable = "Followup, Date of hospital admission since last visit";
        if(conditionConcept) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
  },
  'EOT, Outcome' : function (formName, formFieldValues) {
	var enDOD = "DATE OF DEATH";
	var enCOD = "EOT, Suspected primary cause of death";
	var conditions = {enable : [],disable : []};
	var outcome = formFieldValues['EOT, Outcome'];
	var enSurgery = "EOT, Type of surgery related to death";
	var enNonTB = "EOT, Non TB cause of death";
	var enReason = "EOT, Reasons for failure definition";
	var enOther = "EOT, Other reasons for failure definition";
	if (outcome == "Died") {
		var suspectCause = formFieldValues['EOT, Suspected primary cause of death'];
		if (suspectCause != null) {
			if (suspectCause == "Surgery related death") {
				conditions.enable.push(enDOD, enCOD, enSurgery)
			} else {
				conditions.enable.push(enDOD, enCOD);
				conditions.disable.push(enSurgery);
			}
			if (suspectCause == "Cause other than TB") {
				conditions.enable.push(enNonTB);
			} else {
				conditions.disable.push(enNonTB);
			}
		} else {
			conditions.enable.push(enDOD, enCOD)
		}
		conditions.disable.push(enReason, enOther);
	} else {
		conditions.disable.push(enDOD, enCOD, enSurgery, enNonTB);
	}
	if (outcome == "Failed") {
		conditions.enable.push(enReason);
		var reasonResponse = formFieldValues[enReason];
		var enOther = "EOT, Other reasons for failure definition";
		if (reasonResponse != null) {
			if (reasonResponse.indexOf("Other") > -1) {
				conditions.enable.push(enOther)
			} else {
				conditions.disable.push(enOther);
			}
		} else {
			conditions.enable.push(enDOD, enCOD)
		}
	} else {
		conditions.disable.push(enReason, enOther);
	}
	var enInterruption = "EOT, Reasons for treatment interrruption";
	var enAdditional = "EOT, Additional information on treatment interruption";
	if (outcome == "LTFU") {
		conditions.enable.push(enInterruption, enAdditional);
		var reasonResponse = formFieldValues[enInterruption];
		var enOtherReasons = "EOT, Other reasons for treatment interruption";
		if (reasonResponse != null) {
			if (reasonResponse.indexOf("Other") > -1) {
				conditions.enable.push(enOtherReasons)
			} else {
				conditions.disable.push(enOtherReasons);
			}
		} else {
			conditions.disable.push(enOtherReasons)
		}
	} else {
			conditions.disable.push(enInterruption, enAdditional);
	}
	var enTransferOut = "EOT, Did the patient transfer out";
	var enTransferred = "EOT, Transferred to where";
	var enOtherReason = "EOT, Other reasons for no evaluation of outcome";
	if (outcome == "Not Evaluated") {
		conditions.enable.push(enTransferOut);
		var transferResponse = formFieldValues[enTransferOut];
		if (transferResponse != null) {
			if (transferResponse == true) {
				conditions.enable.push(enTransferred);
				conditions.disable.push(enOtherReason);
			} else if(transferResponse == false){
				conditions.disable.push(enTransferred);
				conditions.enable.push(enOtherReason);
			} else {
				conditions.disable.push(enTransferred,enOtherReason);
			}
		} else {
			conditions.disable.push(enTransferred, enOtherReason);
		}
	} else {
		conditions.disable.push(enTransferOut, enTransferred, enOtherReason);
	}
	return conditions;
  },
  'EOT, Suspected primary cause of death' : function (formName, formFieldValues) {
	var enSurgery = "EOT, Type of surgery related to death";
	var enNonTB = "EOT, Non TB cause of death";
	var conditions = {enable : [],disable : []};
	var suspectCause = formFieldValues['EOT, Suspected primary cause of death'];
	if (suspectCause == "Surgery related death") {
		conditions.enable.push(enSurgery, enNonTB)
	} else {
		conditions.disable.push(enSurgery);
	}
	if (suspectCause == "Cause other than TB") {
		conditions.enable.push(enNonTB);
	} else {
		conditions.disable.push(enNonTB);
	}
	return conditions;
  },
  'EOT, Reasons for failure definition' : function (formName, formFieldValues) {
	var enOther = "EOT, Other reasons for failure definition";
	var conditions = {enable : [],disable : []};
	var suspectCause = formFieldValues['EOT, Reasons for failure definition'];
	if (suspectCause != null) {
		if (suspectCause.indexOf("Other") > -1) {
			conditions.enable.push(enOther)
		} else {
			conditions.disable.push(enOther);
		}
	} else {
		conditions.disable.push(enOther);
	}
	return conditions;
  },
  'EOT, Reasons for treatment interrruption' : function (formName, formFieldValues) {
	var enOther = "EOT, Other reasons for treatment interruption";
	var conditions = {enable : [],disable : []};
	var suspectCause = formFieldValues['EOT, Reasons for treatment interrruption'];
	if (suspectCause != null) {
		if (suspectCause.indexOf("Other") > -1) {
			conditions.enable.push(enOther)
		} else {
			conditions.disable.push(enOther);
		}
	} else {
		conditions.disable.push(enOther);
	}
	return conditions;
  },
  'EOT, Did the patient transfer out' : function (formName, formFieldValues) {
	var enTransferred = "EOT, Transferred to where"
	var enOtherReason = "EOT, Other reasons for no evaluation of outcome";
	var conditions = {enable : [],disable : []};
	var transferResponse = formFieldValues['EOT, Did the patient transfer out'];
	if (transferResponse == true) {
		conditions.enable.push(enTransferred);
		conditions.disable.push(enOtherReason);
	} else if(transferResponse == false) {
		conditions.disable.push(enTransferred);
		conditions.enable.push(enOtherReason);
	} else {
		conditions.disable.push(enTransferred,enOtherReason);
	}
	return conditions;
  },
  '6m PTO, 6 month post treatment outcome': function(formName, formFieldValues) {
        var conceptToEnable_dateOfDeath = "DATE OF DEATH";
        var conceptToEnable_causeOfDeath = "6m PTO, Suspected primary cause of death";
        var conceptToEnable_reason = "6m PTO, Reasons for no post treatment followup";
        var conceptToEnable_commentsOnNoFup = "6m PTO, Comments on no post treatment followup";        
        var conceptToEnable_transfer = "6m PTO, Transfer out post treatment";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['6m PTO, 6 month post treatment outcome'];
	var conceptToEnable_surgeryType = "6m PTO, Type of surgery related to post treatment death";
	var conceptToEnable_nonTBCauseOfDeath = "6m PTO, Non TB cause of post treatment death";
        if(conditionConcept == "Died post treatment" ) {
		conditions.enable.push(conceptToEnable_dateOfDeath, conceptToEnable_causeOfDeath);
		var causeOfDeathValue = formFieldValues['6m PTO, Suspected primary cause of death'];
		if(causeOfDeathValue == "Surgery related death" ) {
			conditions.enable.push(conceptToEnable_surgeryType)
		} else {
			conditions.disable.push(conceptToEnable_surgeryType)
		}
		if(causeOfDeathValue == "Cause other than TB" ) {
			conditions.enable.push(conceptToEnable_nonTBCauseOfDeath)
		} else {
			conditions.disable.push(conceptToEnable_nonTBCauseOfDeath)
		}
        } else {
            	conditions.disable.push(conceptToEnable_dateOfDeath, conceptToEnable_causeOfDeath, conceptToEnable_surgeryType, conceptToEnable_nonTBCauseOfDeath);
        }
	var conceptToEnable_otherReason = "6m PTO, Other reasons for no post treatment followup";
        if(conditionConcept == "LTFU post treatment" ) {
        	conditions.enable.push(conceptToEnable_reason, conceptToEnable_commentsOnNoFup)
        	var reasonForNoPostTreatment = formFieldValues['6m PTO, Reasons for no post treatment followup'];    
		if(reasonForNoPostTreatment!=null) {
			if(reasonForNoPostTreatment.indexOf("Other") != -1 ) {
				conditions.enable.push(conceptToEnable_otherReason, "6m PTO, Comments on no post treatment followup")
			} else {
				conditions.disable.push(conceptToEnable_otherReason, "6m PTO, Comments on no post treatment followup")
			}
		}   
        } else {
            conditions.disable.push(conceptToEnable_reason, conceptToEnable_commentsOnNoFup, conceptToEnable_otherReason)
        }
	var conceptToEnable_onYes = "6m PTO, Transferred to where post treatment";
        var conceptToEnable_onNo = "6m PTO, Other reasons for no post treatment outcome";
        if(conditionConcept == "Not Evaluated" ) {
        	conditions.enable.push(conceptToEnable_transfer);
        	var notEvaluatedValue = formFieldValues['6m PTO, Transfer out post treatment'];
        	if(notEvaluatedValue == true ) {
			conditions.enable.push(conceptToEnable_onYes)
		} else {
			conditions.disable.push(conceptToEnable_onYes)
		}
		if(notEvaluatedValue == false ) {
			conditions.enable.push(conceptToEnable_onNo)
		} else {
			conditions.disable.push(conceptToEnable_onNo)
		}
	} else {
        	conditions.disable.push(conceptToEnable_transfer, conceptToEnable_onYes, conceptToEnable_onNo)
        }
        return conditions;
  },
  '6m PTO, Suspected primary cause of death': function (formName, formFieldValues) {
	var conceptToEnable_surgeryType = "6m PTO, Type of surgery related to post treatment death";
	var conceptToEnable_nonTBCauseOfDeath = "6m PTO, Non TB cause of post treatment death";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['6m PTO, Suspected primary cause of death'];    
	if(conditionConcept == "Surgery related death" ) {
		conditions.enable.push(conceptToEnable_surgeryType)
	} else {
	conditions.disable.push(conceptToEnable_surgeryType)
	}
	if(conditionConcept == "Cause other than TB" ) {
		conditions.enable.push(conceptToEnable_nonTBCauseOfDeath)
	} else {
		conditions.disable.push(conceptToEnable_nonTBCauseOfDeath)
	}		
        return conditions;
  },
  '6m PTO, Reasons for no post treatment followup': function (formName, formFieldValues) {
        var conceptToEnable = "6m PTO, Other reasons for no post treatment followup";
	var conditions = {enable: [], disable: []};
	var SAETerm = formFieldValues['6m PTO, Reasons for no post treatment followup'];    
	if(SAETerm!=null) {
		if(SAETerm.indexOf("Other") != -1 ) {
			conditions.enable.push(conceptToEnable, "6m PTO, Comments on no post treatment followup")
		} else {
			conditions.disable.push(conceptToEnable, "6m PTO, Comments on no post treatment followup")
		}
	}    
        return conditions;
  },
  '6m PTO, Transfer out post treatment': function(formName, formFieldValues) {
        var conceptToEnable_onYes = "6m PTO, Transferred to where post treatment";
        var conceptToEnable_onNo = "6m PTO, Other reasons for no post treatment outcome";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['6m PTO, Transfer out post treatment'];    
	if(conditionConcept == true ) {
		conditions.enable.push(conceptToEnable_onYes)
	} else {
		conditions.disable.push(conceptToEnable_onYes)
	}
	if(conditionConcept == false ) {
		conditions.enable.push(conceptToEnable_onNo)
	} else {
		conditions.disable.push(conceptToEnable_onNo)
	}    
        return conditions;
  },
  'AE Form, AE term comprehensive list' : function (formName, formFieldValues) {
	var conceptToEnable = "AE Form, Other AE term";
	var conditions = {enable : [],disable : []};
	var AETerm = formFieldValues['AE Form, AE term comprehensive list'];
	if (AETerm == "Other") {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
	return conditions;
  },
  'AE Form, AE related to TB drugs' : function (formName, formFieldValues) {
	var conceptToEnable = "AE Form, TB drug treatment";
	var conditions = {enable : [],disable : []};
	var condtionalConcept = formFieldValues['AE Form, AE related to TB drugs'];
	if (condtionalConcept == true) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
	return conditions;
  },
  'AE Form, Other causal factors related to AE' : function (formName, formFieldValues) {
	var enNonTBDrug = "AE Form, Non TB drug of other causal factor";
	var enComorbidity = "AE Form, Comorbidity of other causal facrtor";
	var enOtherCausalFactors = "AE Form, Other causal factor";
	var conditions = {enable : [],disable : []};
	var anyFactor = formFieldValues['AE Form, Other causal factors related to AE'];
	if (anyFactor != null) {
		if (anyFactor.indexOf("Non TB drugs") > -1) {
			conditions.enable.push(enNonTBDrug)
		} else {
			conditions.disable.push(enNonTBDrug)
		}
		if (anyFactor.indexOf("Co-morbidity") > -1) {
			conditions.enable.push(enComorbidity)
		} else {
			conditions.disable.push(enComorbidity)
		}
		if (anyFactor.indexOf("Other") > -1) {
			conditions.enable.push(enOtherCausalFactors)
		} else {
			conditions.disable.push(enOtherCausalFactors)
		}
	} else {
		conditions.disable.push(enNonTBDrug, enComorbidity, enOtherCausalFactors)
	}
	return conditions;
  },
  'SAE Form, SAE term comprehensive AE list' : function (formName, formFieldValues) {
	var conceptToEnable = "SAE Form, Other SAE term";
	var conditions = {enable : [],disable : []};
	var SAETerm = formFieldValues['SAE Form, SAE term comprehensive AE list'];
	if (SAETerm == "Other") {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
	return conditions;
  },
  'SAE Form, Other causal factors related to SAE' : function (formName, formFieldValues) {
	var enNonTBDrug = "SAE Form, Non TB drug of ther causal factors";
	var enComorbidity = "SAE Form, Comorbidity of other causal factors";
	var enOtherCausalFactors = "SAE Form, Other causal factor";
	var conditions = {enable : [],disable : []};
	var anyFactor = formFieldValues['SAE Form, Other causal factors related to SAE'];
	if (anyFactor != null) {
		if (anyFactor.indexOf("Non TB drugs") > -1) {
			conditions.enable.push(enNonTBDrug)
		} else {
			conditions.disable.push(enNonTBDrug)
		}
		if (anyFactor.indexOf("Co-morbidity") > -1) {
			conditions.enable.push(enComorbidity)
		} else {
			conditions.disable.push(enComorbidity)
		}
		if (anyFactor.indexOf("Other") > -1) {
			conditions.enable.push(enOtherCausalFactors)
		} else {
			conditions.disable.push(enOtherCausalFactors)
		}
	} else {
		conditions.disable.push(enNonTBDrug, enComorbidity, enOtherCausalFactors)
	}
	return conditions;
  },
  'PRF, Pregnancy in TB patient or partner': function (formName, formFieldValues) {
        var conceptToEnable_dob = "PRF, Date of birth of partner";
        var conceptToEnable_partner = "PRF, Partners initials";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['PRF, Pregnancy in TB patient or partner'];   
	if(conditionConcept == "Partner" ) {
		conditions.enable.push(conceptToEnable_partner, conceptToEnable_dob)
	} else {
		conditions.disable.push(conceptToEnable_partner, conceptToEnable_dob)
	}
        return conditions;
  },
  'PRF, Complication during pregnancy': function (formName, formFieldValues) {
        var conceptToEnable = "PRF, Explain pregnancy complications";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['PRF, Complication during pregnancy'];    
	if(conditionConcept == true ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
        return conditions;
  },
  'PRF, Gave birth to a live child': function (formName, formFieldValues) {
        var conceptToEnable_true = "PRF, Date of delivery";
        var conceptToEnable_false = "PRF, Reason for not giving birth to a live child";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['PRF, Gave birth to a live child'];    
	if(conditionConcept == true ) {
		conditions.enable.push(conceptToEnable_true)
	} else {
		conditions.disable.push(conceptToEnable_true)
	}
	if(conditionConcept == false ) {
		conditions.enable.push(conceptToEnable_false)
	} else {
		conditions.disable.push(conceptToEnable_false)
	}
        return conditions;
  },
  'PRF, Infant normal at birth': function (formName, formFieldValues) {
        var conceptToEnable = "PRF, Reason for infant abnormal at birth";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['PRF, Infant normal at birth'];    
	if(conditionConcept == false ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}    
        return conditions;
  },
  'HDS, Reason for hospitalization': function causeOfDeathLogics(formName, formFieldValues) {
        var conceptToEnable = "HDS, Principal AE/SAE ID number";
	var conceptEnSurgery = "HDS, TB related surgery while hospitalization";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['HDS, Reason for hospitalization'];    
	if(conditionConcept == "Adverse event" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
	if(conditionConcept == "Surgical operation" ){
		conditions.enable.push(conceptEnSurgery)
	} else {
		conditions.disable.push(conceptEnSurgery)
	}
        return conditions; 
  },
  'HDS, New AE/SAE reported': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['HDS, New AE/SAE reported'];
        var conceptToEnable = "HDS, New AE/SAE ID number";
        if(conditionConcept == true) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
  },
  'HDS, TB related surgery while hospitalization': function causeOfDeathLogics(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};	
	var conditionConcept = formFieldValues['HDS, TB related surgery while hospitalization'];    		
	if(conditionConcept == true) {
		conditions.enable.push("HDS, TB related surgery date", "HDS, Type of TB related surgery", "HDS, Side of TB related surgery", "HDS, Indication of TB related surgery");
		var values1 = formFieldValues['HDS, Type of TB related surgery'];  
		if(values1 == "Other" ) {
			conditions.enable.push("HDS, Other type of TB related surgery")
		} else {
			conditions.disable.push("HDS, Other type of TB related surgery")
		}
		
		var values2 = formFieldValues['HDS, Indication of TB related surgery'];  
		if(values2 == "Other" ) {
			conditions.enable.push("HDS, Other indication of TB related surgery")
		} else {
			conditions.disable.push("HDS, Other indication of TB related surgery")
		}
	} else {
		conditions.disable.push("HDS, TB related surgery date", "HDS, Type of TB related surgery", "HDS, Side of TB related surgery", "HDS, Indication of TB related surgery")
	}
        return conditions; 
  },
  'HDS, Type of TB related surgery': function causeOfDeathLogics(formName, formFieldValues) {
        var conceptToEnable = "HDS, Other type of TB related surgery";
        var conditions = {enable: [], disable: []};	
	var conditionConcept = formFieldValues['HDS, Type of TB related surgery'];    
	if (conditionConcept != null) {
                        if (conditionConcept.indexOf("Other") > -1) {
                                conditions.enable.push("HDS, Other type of TB related surgery");
                        } else {
                                conditions.disable.push("HDS, Other type of TB related surgery");
                        }
	} else {
        	conditions.disable.push("HDS, Other type of TB related surgery");
        }
        return conditions; 
  },
  'HDS, Indication of TB related surgery': function causeOfDeathLogics(formName, formFieldValues) {
        var conceptToEnable = "HDS, Other indication of TB related surgery";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['HDS, Indication of TB related surgery'];    
	if(conditionConcept == "Other" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}        
        return conditions;
  },
  'Lab, Type of visit': function (formName, formFieldValues) {
        var conceptToEnable = "Lab, Month of scheduled visit";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, Type of visit'];    
	if(conditionConcept == "Scheduled monthly visit" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
        return conditions; 
  },
  'Lab, Hemoglobin test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "Hemoglobin";
        var conceptToEnable2 = "Lab, Hemoglobin Abnormal";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, Hemoglobin test done'];    
	if(conditionConcept == true ) {
		conditions.enable.push(conceptToEnable1, conceptToEnable2)
	} else {
		conditions.disable.push(conceptToEnable1, conceptToEnable2)
	}
        return conditions;
  },
  'Lab, Hematocrit test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "HEMATOCRIT";
        var conceptToEnable2 = "Lab, Hematocrit Abnormal";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, Hematocrit test done'];    
	
	if(conditionConcept == true ) {
		conditions.enable.push(conceptToEnable1, conceptToEnable2)
	} else {
		conditions.disable.push(conceptToEnable1, conceptToEnable2)
	}
        return conditions;
  },
  'Lab, Platelet count test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "Platelets";
        var conceptToEnable2 = "Lab, Platelets Abnormal";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, Platelet count test done'];    
		if(conditionConcept == true ) {
			conditions.enable.push(conceptToEnable1, conceptToEnable2)
		} else {
			conditions.disable.push(conceptToEnable1, conceptToEnable2)
		}
        return conditions;
  },
  'Lab, RBC test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "RED BLOOD CELLS";
        var conceptToEnable2 = "Lab, RBC Abnormal";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, RBC test done'];    
		if(conditionConcept == true ) {
			conditions.enable.push(conceptToEnable1, conceptToEnable2)
		} else {
			conditions.disable.push(conceptToEnable1, conceptToEnable2)
		}
        return conditions;
  },
  'Lab, WBC test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "WHITE BLOOD CELLS";
        var conceptToEnable2 = "Lab, WBC Abnormal";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, WBC test done'];    
		if(conditionConcept == true ) {
			conditions.enable.push(conceptToEnable1, conceptToEnable2)
		} else {
			conditions.disable.push(conceptToEnable1, conceptToEnable2)
		}
        return conditions;
  },
  'Lab, Absolute neutrophil count test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "ABSOLUTE NEUTROPHIL COUNT";
        var conceptToEnable2 = "Lab, Absolute neutrophil count Abnormal";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, Absolute neutrophil count test done'];    
		if(conditionConcept == true ) {
			conditions.enable.push(conceptToEnable1, conceptToEnable2)
		} else {
			conditions.disable.push(conceptToEnable1, conceptToEnable2)
		}
        return conditions;
  },
  'Lab, Neutrophils test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "Lab, Neutrophils test result";
        var conceptToEnable2 = "Lab, Neutrophils Abnormal";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, Neutrophils test done'];    
		if(conditionConcept == true ) {
			conditions.enable.push(conceptToEnable1, conceptToEnable2)
		} else {
			conditions.disable.push(conceptToEnable1, conceptToEnable2)
		}
        return conditions;
  },
  'Lab, Potassium test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "SERUM POTASSIUM";
        var conceptToEnable2 = "Lab, Potassium Abnormal";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, Potassium test done'];    
		if(conditionConcept == true ) {
			conditions.enable.push(conceptToEnable1, conceptToEnable2)
		} else {
			conditions.disable.push(conceptToEnable1, conceptToEnable2)
		}
        return conditions;
  },
  'Lab, Magnesium test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "Lab, Magnesium test result";
        var conceptToEnable2 = "Lab, Magnesium Abnormal";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, Magnesium test done'];    
		if(conditionConcept == true ) {
			conditions.enable.push(conceptToEnable1, conceptToEnable2)
		} else {
			conditions.disable.push(conceptToEnable1, conceptToEnable2)
		}
        return conditions;
  },
  'Lab, Ionized Calcium test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "Lab, Ionized Calcium test result";
        var conceptToEnable2 = "Lab, Ionized Calcium Abnormal";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, Ionized Calcium test done'];    
		if(conditionConcept == true ) {
			conditions.enable.push(conceptToEnable1, conceptToEnable2)
		} else {
			conditions.disable.push(conceptToEnable1, conceptToEnable2)
		}
        return conditions;
  },
  'Lab, Urea test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "BLOOD UREA NITROGEN";
        var conceptToEnable2 = "Lab, Urea Abnormal";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, Urea test done'];    
		if(conditionConcept == true ) {
			conditions.enable.push(conceptToEnable1, conceptToEnable2)
		} else {
			conditions.disable.push(conceptToEnable1, conceptToEnable2)
		}
        return conditions; 
  },
  'Lab, Creatinine test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "Serum creatinine (umol/L)";
        var conceptToEnable2 = "Lab, Creatinine Abnormal";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Lab, Creatinine test done'];    
		if(conditionConcept == true ) {
			conditions.enable.push(conceptToEnable1, conceptToEnable2)
		} else {
			conditions.disable.push(conceptToEnable1, conceptToEnable2)
		}    
        return conditions; 
  },
  'Lab, Glucose test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "SERUM GLUCOSE";
        var conceptToEnable2 = "Lab, Glucose Abnormal";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, Glucose test done'];
                if(conditionConcept == true ) {
                        conditions.enable.push(conceptToEnable1, conceptToEnable2)
                } else {
                        conditions.disable.push(conceptToEnable1, conceptToEnable2)
                }
        return conditions;
  },
  'Lab, Glucose(fasting) test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "Fasting blood glucose measurement (mg/dL)";
        var conceptToEnable2 = "Lab, Glucose (fasting) Abnormal";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, Glucose(fasting) test done'];
                if(conditionConcept == true ) {
                        conditions.enable.push(conceptToEnable1, conceptToEnable2)
                } else {
                        conditions.disable.push(conceptToEnable1, conceptToEnable2)
                }
        return conditions;
  },
  'Lab, HbA1c test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "glycosylated hemoglobin A measurement";
        var conceptToEnable2 = "Lab, HbA1c Abnormal";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, HbA1c test done'];
                if(conditionConcept == true ) {
                        conditions.enable.push(conceptToEnable1, conceptToEnable2)
                } else {
                        conditions.disable.push(conceptToEnable1, conceptToEnable2)
                }
        return conditions;
  },
  'Lab, TSH test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "Thyroid stimulating hormone test";
        var conceptToEnable2 = "Lab, TSH Abnormal";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, TSH test done'];
                if(conditionConcept == true ) {
                        conditions.enable.push(conceptToEnable1, conceptToEnable2)
                } else {
                        conditions.disable.push(conceptToEnable1, conceptToEnable2)
                }
        return conditions;
  },
  'Lab, Lipase test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "Lab, Lipase test result";
        var conceptToEnable2 = "Lab, Lipase Abnormal";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, Lipase test done'];
                if(conditionConcept == true ) {
                        conditions.enable.push(conceptToEnable1, conceptToEnable2)
                } else {
                        conditions.disable.push(conceptToEnable1, conceptToEnable2)
                }
        return conditions;
  },
  'Lab, AST(SGOT) test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "SERUM GLUTAMIC-OXALOACETIC TRANSAMINASE";
        var conceptToEnable2 = "Lab, AST (SGOT) Abnormal";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, AST(SGOT) test done'];
        if(conditionConcept == true ) {
        	conditions.enable.push(conceptToEnable1, conceptToEnable2)
        	var values1 = formFieldValues['Lab, AST (SGOT) Abnormal'];
                if(values1 == "True" ) {
                        conditions.enable.push("Lab, AST (SGOT) upper limit of normal")
                } else {
                        conditions.disable.push("Lab, AST (SGOT) upper limit of normal")
                }        
	} else {
        	conditions.disable.push(conceptToEnable1, conceptToEnable2)
        }
        return conditions;
  },
  'Lab, AST (SGOT) Abnormal': function (formName, formFieldValues) {
        var conceptToEnable1 = "Lab, AST (SGOT) upper limit of normal";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, AST (SGOT) Abnormal'];
                if(conditionConcept == "True" ) {
                        conditions.enable.push(conceptToEnable1)
                } else {
                        conditions.disable.push(conceptToEnable1)
                }
        return conditions;
  },
  'Lab, ALT(SGPT) test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "SERUM GLUTAMIC-PYRUVIC TRANSAMINASE";
        var conceptToEnable2 = "Lab, ALT (SGPT) Abnormal";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, ALT(SGPT) test done'];
        if(conditionConcept == true ) {
                conditions.enable.push(conceptToEnable1, conceptToEnable2)
                var values1 = formFieldValues['Lab, ALT (SGPT) Abnormal'];
                if(values1 == "True" ) {
                        conditions.enable.push("Lab, ALT (SGPT) upper limit of normal")
                } else {
                        conditions.disable.push("Lab, ALT (SGPT) upper limit of normal")
                }
        } else {
                conditions.disable.push(conceptToEnable1, conceptToEnable2)
        }
        return conditions;
  },
  'Lab, ALT (SGPT) Abnormal': function (formName, formFieldValues) {
        var conceptToEnable1 = "Lab, ALT (SGPT) upper limit of normal";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, ALT (SGPT) Abnormal'];
                if(conditionConcept == "True" ) {
                        conditions.enable.push(conceptToEnable1)
                } else {
                        conditions.disable.push(conceptToEnable1)
                }
        return conditions;
  },
  'Lab, Total Bilirubin details test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "TOTAL BILIRUBIN";
        var conceptToEnable2 = "Lab, Total Bilirubin Abnormal";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, Total Bilirubin details test done'];
        if(conditionConcept == true ) {
                conditions.enable.push(conceptToEnable1, conceptToEnable2)
                var values1 = formFieldValues['Lab, Total Bilirubin Abnormal'];
                if(values1 == "True" ) {
                        conditions.enable.push("Lab, Total Bilirubin upper limit of normal")
                } else {
                        conditions.disable.push("Lab, Total Bilirubin upper limit of normal")
                }
        } else {
                conditions.disable.push(conceptToEnable1, conceptToEnable2)
        }
        return conditions;
  },
  'Lab, Total Bilirubin Abnormal': function (formName, formFieldValues) {
        var conceptToEnable1 = "Lab, Total Bilirubin upper limit of normal";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, Total Bilirubin Abnormal'];
                if(conditionConcept == "True" ) {
                        conditions.enable.push(conceptToEnable1)
                } else {
                        conditions.disable.push(conceptToEnable1)
                }
        return conditions;
  },
  'Lab, CD4 count test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "CD4 COUNT";
	var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, CD4 count test done'];
                if(conditionConcept == true ) {
                        conditions.enable.push(conceptToEnable1)
                } else {
                        conditions.disable.push(conceptToEnable1)
                }
        return conditions;
  },
  'Lab, RNA VL test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "HIV VIRAL LOAD";
	var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, RNA VL test done'];
                if(conditionConcept == true ) {
                        conditions.enable.push(conceptToEnable1)
                } else {
                        conditions.disable.push(conceptToEnable1)
                }
        return conditions;
  },
  'Lab, Serum Albumin test done': function (formName, formFieldValues) {
        var conceptToEnable1 = "SERUM ALBUMIN";
        var conceptToEnable2 = "Lab, Serum Albumin Abnormal";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Lab, Serum Albumin test done'];
                if(conditionConcept == true ) {
                        conditions.enable.push(conceptToEnable1, conceptToEnable2)
                } else {
                        conditions.disable.push(conceptToEnable1, conceptToEnable2)
                }
        return conditions;
  },
  'Xray, Type of visit': function(formName, formFieldValues) {
        var conceptToEnable = "Xray, Month of scheduled visit";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Xray, Type of visit'];
        if(conditionConcept == "Scheduled monthly visit" ) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
  },
  'Xray, Extent of disease': function(formName, formFieldValues) {
        var conceptEnCavity = "Xray, Maximum cavity size";
	var conceptEnFibrosis = "Xray, Fibrosis";
	var conceptEnLastXray = "Xray, Comparison with last Xray";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Xray, Extent of disease'];
        if(conditionConcept == "Normal" || !conditionConcept) {
            conditions.disable.push(conceptEnCavity,conceptEnFibrosis,conceptEnLastXray)
        } else {
            conditions.enable.push(conceptEnCavity,conceptEnFibrosis,conceptEnLastXray)
        }
        return conditions;
  },
  'Audiometry, Type of visit': function (formName, formFieldValues) {
        var conceptToEnable = "Audiometry, Month of scheduled visit";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Audiometry, Type of visit'];    
	if(conditionConcept == "Scheduled monthly visit" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
        return conditions;
  },
  'Audiometry, Reporting audiometry related AE': function (formName, formFieldValues) {
	var conceptToEnable = "Audiometry, AE ID number";
	var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Audiometry, Reporting audiometry related AE'];    
	if(conditionConcept == "True" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}    
        return conditions;
  },
  'EKG, Type of visit': function (formName, formFieldValues) {
        var conceptToEnable = "EKG, Month of scheduled visit";
        var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['EKG, Type of visit'];    
	if(conditionConcept == "Scheduled monthly visit" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
	return conditions;
  },
  'EKG, Rythm': function causeOfDeathLogics(formName, formFieldValues) {
        var conceptToEnable = "EKG, Other Rythm";
        var conditions = {enable: [], disable: []};
	var SAETerm = formFieldValues['EKG, Rythm'];    	
	if(SAETerm == "Other" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
	return conditions;
  },
  'MTC, Treatment delivery method': function (formName, formFieldValues) {
	var conceptToEnable = "MTC, Other treatment delivery method";
	var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['MTC, Treatment delivery method'];    
	if(conditionConcept == "Other" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
	return conditions;
  },
  'Performance Status, Type of visit': function causeOfDeathLogics(formName, formFieldValues) {
	var conceptToEnable = "Performance Status, Month of scheduled visit";
	var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Performance Status, Type of visit'];    
	if(conditionConcept == "Scheduled monthly visit" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
	return conditions;
  },
  '': function(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues[''];
	var conceptToEnable = "";
        if(conditionConcept=="") {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
  },
  'Bacteriology, Smear result':  function (formName, formFieldValues) {
  	var conceptToEnable = "Bacteriology, Smear result positivity";
	var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Bacteriology, Smear result'];    
	if(conditionConcept == "Positive" ) {
		conditions.enable.push(conceptToEnable)
	} else {
		conditions.disable.push(conceptToEnable)
	}
	return conditions;
  },
  'Bacteriology, Xpert MTB result':  function (formName, formFieldValues) {
  	var burdenconceptToEnable = "Bacteriology, MTB Burden";
  	var rifconceptToEnable =	"Bacteriology, RIF resistance result type"
	var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Bacteriology, Xpert MTB result'];    
	if(conditionConcept == "Detected" ) {
		conditions.enable.push(burdenconceptToEnable)
		conditions.enable.push(rifconceptToEnable)
	} else {
		conditions.disable.push(burdenconceptToEnable)
		conditions.disable.push(rifconceptToEnable)
	}
	return conditions;
  },
  'Bacteriology, HAIN MTBDRsl test result': function (formName, formFieldValues) {
  	var fluoroquinoloneconceptToEnable = "Bacteriology, Fluoroquinolone";
  	var aminoglycosideconceptToEnable =	"Bacteriology, Aminoglycoside"
	var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Bacteriology, HAIN MTBDRsl test result'];    
	if(conditionConcept == "Detected" ) {
		conditions.enable.push(fluoroquinoloneconceptToEnable)
		conditions.enable.push(aminoglycosideconceptToEnable)
	} else {
		conditions.disable.push(fluoroquinoloneconceptToEnable)
		conditions.disable.push(aminoglycosideconceptToEnable)
	}
	return conditions;
  },
  'Bacteriology, Type of culture medium': function (formName, formFieldValues) {
  	var otherCultureconceptToEnable =	"Bacteriology, Other culture medium"
	var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Bacteriology, Type of culture medium'];    
	if(conditionConcept == "Other" ) {
		conditions.enable.push(otherCultureconceptToEnable)
	} else {
		conditions.disable.push(otherCultureconceptToEnable)
	}
	return conditions;
  },
  'Bacteriology, Culture results': function (formName, formFieldValues) {
  	var cultureColonyconceptToEnable = "Bacteriology, Culture Colonies"
	var conditions = {enable: [], disable: []};
	var conditionConcept = formFieldValues['Bacteriology, Culture results'];    
	if(conditionConcept == "Positive for M. tuberculosis" ) {
		conditions.enable.push(cultureColonyconceptToEnable)
	} else {
		conditions.disable.push(cultureColonyconceptToEnable)
	}
	return conditions;
  },
  'Baseline, Marital Status': function (formName, formFieldValues) {
  var conceptToEnable = "Baseline, Other Marital Status"
  var conditions = {enable: [], disable: []};
  var conditionConcept = formFieldValues['Baseline, Marital Status'];    
  if(conditionConcept == "Other" ) {
    conditions.enable.push(conceptToEnable)
  } else {
    conditions.disable.push(conceptToEnable)
  }
  return conditions;
  },
  'Bacteriology, HAIN MTBDRplus test result': function (formName, formFieldValues) {
  var conceptToEnable_isoniazid = "Bacteriology, Isoniazid"
  var conceptToEnable_rifampicin =  "Bacteriology, Rifampicin"
  var conditions = {enable: [], disable: []};
  var conditionConcept = formFieldValues['Bacteriology, HAIN MTBDRplus test result'];    
  if(conditionConcept == "Detected" ) {
    conditions.enable.push(conceptToEnable_isoniazid)
    conditions.enable.push(conceptToEnable_rifampicin)
  } else {
    conditions.disable.push(conceptToEnable_isoniazid)
    conditions.disable.push(conceptToEnable_rifampicin)
  }
  return conditions;
  },
  "Bacteriology, Type of Visit": function (formName, formFieldValues) {
  var conceptToEnable = "Bacteriology, Which monthly scheduled visit"
  var conditions = {enable: [], disable: []};
  var conditionConcept = formFieldValues['Bacteriology, Type of Visit'];    
  if(conditionConcept == "Scheduled monthly visit" ) {
    conditions.enable.push(conceptToEnable)
  } else {
    conditions.disable.push(conceptToEnable)
  }
  return conditions;
  }
};
