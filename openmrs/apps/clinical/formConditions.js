Bahmni.ConceptSet.FormConditions.rules = {      //This is a constant that Bahmni expects
    'Baseline, Employment within the past year': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Employment within the past year'];
        if (conditionConcept == "Other") {
            conditions.enable.push("Baseline, Other employment")
        } else {
            conditions.disable.push("Baseline, Other employment")
        }
        return conditions;
    },
    'Baseline, Prison': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Prison'];
        if (conditionConcept == "True") {
            conditions.enable.push("Baseline, Is prison past or present")
        } else {
            conditions.disable.push("Baseline, Is prison past or present")
        }
        return conditions;
    },
    'Baseline, Is alcoholic': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Is alcoholic'];
        if (conditionConcept == "True") {
            conditions.enable.push("Baseline, How many alcoholic drinks per week")
        } else {
            conditions.disable.push("Baseline, How many alcoholic drinks per week")
        }
        return conditions;
    },
    'Baseline, HIV serostatus result': function (formName, formFieldValues) {
        var conditions = {
            enable: [],
            disable: []
        };
        var conditionConcept = formFieldValues['Baseline, HIV serostatus result'];
        if (conditionConcept == "Positive") {
            conditions.enable.push("Baseline, HIV program registration number", "Date of HIV diagnosis", "Baseline, CD4 count details", "CD4 date", "Baseline, HIV Viral Load Details", "Baseline, Viral Load Date", "Antiretroviral treatment start date", "Baseline, On ARV treatment", "Baseline, Drugs used in ARV treatment")
        } else {
            conditions.disable.push("Baseline, HIV program registration number", "Date of HIV diagnosis", "Baseline, CD4 count details", "CD4 date", "Baseline, HIV Viral Load Details", "Baseline, Viral Load Date", "Antiretroviral treatment start date", "Baseline, On ARV treatment", "Baseline, Drugs used in ARV treatment")
        }
        return conditions;
    },
    'Baseline, Reason for next assessment': function (formName, formFieldValues) {
        var otherReasonLine = "Baseline, Other assessment reason";
        var conditionConcept = formFieldValues['Baseline, Reason for next assessment'];
        if (conditionConcept == 'Other assessment') {
            return {enable: [otherReasonLine]}
        } else {
            return {disable: [otherReasonLine]}
        }
    },
    'Diabetes Mellitus': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Diabetes Mellitus'];
        if (conditionConcept == "True") {
            conditions.enable.push("glycosylated hemoglobin A measurement")
        } else {
            conditions.disable.push("glycosylated hemoglobin A measurement")
        }
        return conditions;
    },
    'Baseline, Has cancer': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Has cancer'];
        if (conditionConcept == "True") {
            conditions.enable.push("Baseline, Cancer type")
        } else {
            conditions.disable.push("Baseline, Cancer type")
        }
        return conditions;
    },
    'Baseline, Heart or atherosclerotic disease': function (formName, formFieldValues) {
        var conditions = {
            enable: [],
            disable: []
        };
        var conditionConcept = formFieldValues['Baseline, Heart or atherosclerotic disease'];
        if (conditionConcept == "True") {
            conditions.enable.push("Baseline, Type of heart disease")
        } else {
            conditions.disable.push("Baseline, Type of heart disease")
        }
        return conditions;
    },
    'Baseline, Has other psychiatric illness': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Has other psychiatric illness'];
        if (conditionConcept == "True") {
            conditions.enable.push("Baseline, Psychiatric illness type")
        } else {
            conditions.disable.push("Baseline, Psychiatric illness type")
        }
        return conditions;
    },
    'Baseline, Pre-existing neuropathy': function (formName, formFieldValues) {
        var conditions = {
            enable: [],
            disable: []
        };
        var conditionConcept = formFieldValues['Baseline, Pre-existing neuropathy'];
        if (conditionConcept == "True") {
            conditions.enable.push("Baseline, Neuropathy grade")
        } else {
            conditions.disable.push("Baseline, Neuropathy grade")
        }
        return conditions;
    },
    'Baseline, WHO registration group': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, WHO registration group'];
        if (conditionConcept == "Relapse" || conditionConcept == "Treatment after loss to followup" || conditionConcept == "Treatment After Failure to Drugs" || conditionConcept == "Other previously treated patients") {
            conditions.enable.push("Category IV tuberculosis classification")
        } else {
            conditions.disable.push("Category IV tuberculosis classification")
        }
        return conditions;
    },
    'Baseline, Disease site': function (formName, formFieldValues) {
        var conditions = {
            enable: [],
            disable: []
        };
        var enExtraPul = "Baseline, Exact extrapulmonary site";
        var conditionConcept = formFieldValues['Baseline, Disease site'];
        if (conditionConcept && conditionConcept.indexOf("Extrapulmonary") > -1) {
            conditions.enable.push(enExtraPul);
        } else {
            conditions.disable.push(enExtraPul);
        }
        return conditions;
    },
    'Baseline, MDR-TB diagnosis method': function (formName, formFieldValues) {
        var conditions = {
            enable: [],
            disable: []
        };
        var conditionConcept = formFieldValues['Baseline, MDR-TB diagnosis method'];
        if (conditionConcept == "Bacteriologically Confirmed") {
            conditions.enable.push("Baseline, Method of MDR-TB confirmation");
        } else {
            conditions.disable.push("Baseline, Method of MDR-TB confirmation", "Baseline, Other method of MDR-TB confirmation")
        }
        return conditions;
    },
    'Baseline, Method of MDR-TB confirmation': function (formName, formFieldValues) {
        var conditions = {
            enable: [],
            disable: []
        };
        var conditionConcept = formFieldValues['Baseline, Method of MDR-TB confirmation'];
        if (conditionConcept != null) {
            if (conditionConcept.indexOf("Other") > -1) {
                conditions.enable.push("Baseline, Other method of MDR-TB confirmation")
            }
            else {
                conditions.disable.push("Baseline, Other method of MDR-TB confirmation")
            }
        }
        else {
            conditions.disable.push("Baseline, Other method of MDR-TB confirmation")
        }
        return conditions;
    },
    'Baseline, Drug resistance': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Drug resistance'];
        if (conditionConcept == "Confirmed drug resistant TB") {
            conditions.enable.push("Baseline, Subclassification for confimed drug resistant cases")
        } else {
            conditions.disable.push("Baseline, Subclassification for confimed drug resistant cases")
        }
        return conditions;
    },
    'Baseline, Drug Allergies': function (formName, formFieldValues) {
        var conditions = {
            enable: [],
            disable: []
        };
        var conditionConcept = formFieldValues['Baseline, Drug Allergies'];
        if (conditionConcept == "True") {
            conditions.enable.push("Baseline, Which Drug Allergies")
        } else {
            conditions.disable.push("Baseline, Which Drug Allergies")
        }
        return conditions;
    },
    'Baseline, Has the patient ever been treated for TB in the past?': function (formName, formFieldValues) {
        var conditions = {
            enable: [],
            disable: []
        };
        var conditionConcept = formFieldValues['Baseline, Has the patient ever been treated for TB in the past?'];
        if (conditionConcept == "True") {
            conditions.enable.push("Baseline, If Yes, What was the year of the patients start of first TB treatment Details", "Baseline, Treatment for drug-susceptible TB", "Baseline, Treatment for drug-resistant TB");
        } else {
            conditions.disable.push("Baseline, If Yes, What was the year of the patients start of first TB treatment Details", "Baseline, Treatment for drug-susceptible TB", "Baseline, Treatment for drug-resistant TB");
        }
        return conditions;
    },
    'Baseline, Treatment for drug-susceptible TB': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Treatment for drug-susceptible TB'];
        if (conditionConcept == "True") {
            conditions.enable.push("Baseline, How many drug-susceptible TB treatments", "Baseline, What is the outcome of the last DSTB treatment", "Baseline, Last DSTB Registration ID Details", "Baseline, Last DSTB treatment registration facility")
        } else {
            conditions.disable.push("Baseline, How many drug-susceptible TB treatments", "Baseline, What is the outcome of the last DSTB treatment", "Baseline, Last DSTB Registration ID Details", "Baseline, Last DSTB treatment registration facility")
        }
        return conditions;
    },
    'Baseline, Treatment for drug-resistant TB': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Treatment for drug-resistant TB'];
        if (conditionConcept == "True") {
            conditions.enable.push("Baseline, How many drug-resistant TB treatments", "Baseline, What is the outcome of the last DRTB treatment", "Baseline, Last DRTB Registration ID Details", "Baseline, Last DRTB treatment registration facility")
        } else {
            conditions.disable.push("Baseline, How many drug-resistant TB treatments", "Baseline, What is the outcome of the last DRTB treatment", "Baseline, Last DRTB Registration ID Details", "Baseline, Last DRTB treatment registration facility")
        }
        return conditions;
    },
    'TI, Did the patient start treatment': function (formName, formFieldValues) {
        var enStartDate = "TUBERCULOSIS DRUG TREATMENT START DATE";
        var enReason = "TI, Reason for not starting treatment";
        var txFacility = "TI, Treatment facility at start";
        var txRegimen = "TI, Type of treatment regimen";
        var firstLine = "TI, First line drug regimen type";
        var secondLine = "TI, Second line regimen drug type";
        var dateOfDeath = "TI, Date of death before treatment start";
        var conditionConcept = formFieldValues['TI, Did the patient start treatment'];
        if (conditionConcept == false) {
            return {enable: [enReason], disable: [enStartDate, txFacility, txRegimen, firstLine, secondLine]}
        } else if (conditionConcept == true) {
            return {enable: [enStartDate, txFacility, txRegimen], disable: [enReason, dateOfDeath]}
        }
        else {
            return {disable: [enStartDate, txFacility, txRegimen, firstLine, secondLine, enReason, dateOfDeath]}
        }
    },
    'TI, Type of treatment regimen': function (formName, formFieldValues) {
        var txRegimen = "TI, Type of treatment regimen";
        var firstLine = "TI, First line drug regimen type";
        var secondLine = "TI, Second line regimen drug type";
        var conditionConcept = formFieldValues['TI, Type of treatment regimen'];
        if (conditionConcept == 'Only 1st line drugs') {
            return {enable: [firstLine], disable: [secondLine]}
        } else if (conditionConcept == 'Regimen including 2nd line drugs') {
            return {enable: [secondLine], disable: [firstLine]}
        } else {
            return {disable: [firstLine, secondLine]}
        }
    },
    'TI, Currently pregnant': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['TI, Currently pregnant'];
        if (conditionConcept == "True") {
            conditions.enable.push("Estimated date of confinement")
        } else {
            conditions.disable.push("Estimated date of confinement")
        }
        return conditions;
    },
    'TI, Eligible for new drugs': function (formName, formFieldValues) {
        var conditions = {
            enable: [],
            disable: []
        };
        var enDate = "TI, Date of eligibility for new drugs";
        var en4Drugs = "ti_patients_const_four_drug_regimen_not_possible";
        var enUnfavourable = "ti_oth_patient_high_risk_unfavourable";
        var result = formFieldValues['TI, Eligible for new drugs'];
        if (result == "True") {
            conditions.enable.push(enDate, en4Drugs, enUnfavourable);
        } else {
            conditions.disable.push(enDate, en4Drugs, enUnfavourable);
        }
        return conditions;
    },
    'TI, Reason for not starting treatment': function (formName, formFieldValues) {
        var conditionConcept = formFieldValues['TI, Reason for not starting treatment'];
        var deathDT = "TI, Date of death before treatment start";

        if (conditionConcept == "Died") {
            return {enable: [deathDT]}
        } else {
            return {disable: [deathDT]}
        }
    },
    'TI, Reason for next assessment': function (formName, formFieldValues) {
        var otherReasonLine = "TI, Other assessment reason";
        var conditionConcept = formFieldValues['TI, Reason for next assessment'];
        if (conditionConcept == 'Other assessment') {
            return {enable: [otherReasonLine]}
        } else {
            return {disable: [otherReasonLine]}
        }
    },
    'Followup, Currently Pregnant': function (formName, formFieldValues) {
        var conceptToEnable = "Followup, Pregnancy form case ID number";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Followup, Currently Pregnant'];
        if (conditionConcept == "True") {
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
        if (conditionConcept == "True") {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'Followup, New AE reported': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Followup, New AE reported'];
        var conceptToEnable = "Followup, New AE reference number";
        var conceptEnSAE = "Followup, New serious AE reported";
        var conceptSAERefNum = "Followup, New serious AE reference number";
        if (conditionConcept != null) {
            if (conditionConcept == true) {
                conditions.enable.push(conceptToEnable, conceptEnSAE, conceptSAERefNum)
            } else {
                conditions.disable.push(conceptToEnable, conceptEnSAE, conceptSAERefNum)
            }
        } else {
            conditions.disable.push(conceptToEnable, conceptEnSAE, conceptSAERefNum)
        }
        return conditions;
    },
    'Followup, New serious AE reported': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Followup, New serious AE reported'];
        var conceptToEnable = "Followup, New serious AE reference number";
        if (conditionConcept) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'Followup, Admitted into a hospital for any reason': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Followup, Admitted into a hospital for any reason'];
        var conceptToEnable = "Followup, Date of hospital admission since last visit";
        if (conditionConcept) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'Followup, Reason for next visit': function (formName, formFieldValues) {
        var otherReasonLine = "Followup, Other assessment reason";
        var conditionConcept = formFieldValues['Followup, Reason for next visit'];
        if (conditionConcept == 'Other assessment') {
            return {enable: [otherReasonLine]}
        } else {
            return {disable: [otherReasonLine]}
        }
    },
    'EOT, Outcome': function (formName, formFieldValues) {
        var enDOD = "DATE OF DEATH";
        var enCOD = "EOT, Suspected primary cause of death";
        var conditions = {enable: [], disable: []};
        var outcome = formFieldValues['EOT, Outcome'];
        var enSurgery = "EOT, Type of surgery related to death";
        var enNonTB = "EOT, Non TB cause of death";
        var enReason = "EOT, Reasons for failure definition";
        var enOther = "EOT, Other reasons for failure definition";
        if (outcome == "Died") {
            conditions.enable.push(enDOD, enCOD);
        } else {
            conditions.disable.push(enDOD, enCOD, enSurgery, enNonTB);
        }
        if (outcome == "Failed") {
            conditions.enable.push(enReason);
        } else {
            conditions.disable.push(enReason, enOther);
        }
        var enInterruption = "EOT, Reasons for treatment interrruption";
        var enAdditional = "EOT, Additional information on treatment interruption";
        var enOtherReasons = "EOT, Other reasons for treatment interruption";
        if (outcome == "LTFU") {
            conditions.enable.push(enInterruption, enAdditional);
        } else {
            conditions.disable.push(enInterruption, enAdditional, enOtherReasons);
        }
        var enTransferOut = "EOT, Did the patient transfer out";
        var enTransferred = "EOT, Transferred to where";
        var enOtherReason = "EOT, Other reasons for no evaluation of outcome";
        if (outcome == "Not Evaluated") {
            conditions.enable.push(enTransferOut);
        } else {
            conditions.disable.push(enTransferOut, enTransferred, enOtherReason);
        }
        return conditions;
    },
    'EOT, Suspected primary cause of death': function (formName, formFieldValues) {
        var enSurgery = "EOT, Type of surgery related to death";
        var enNonTB = "EOT, Non TB cause of death";
        var conditions = {enable: [], disable: []};
        var suspectCause = formFieldValues['EOT, Suspected primary cause of death'];
        if (suspectCause == "Surgery related death") {
            conditions.enable.push(enSurgery)
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
    'EOT, Reasons for failure definition': function (formName, formFieldValues) {
        var enOther = "EOT, Other reasons for failure definition";
        var conditions = {enable: [], disable: []};
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
    'EOT, Reasons for treatment interrruption': function (formName, formFieldValues) {
        var enOther = "EOT, Other reasons for treatment interruption";
        var conditions = {enable: [], disable: []};
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
    'EOT, Did the patient transfer out': function (formName, formFieldValues) {
        var enTransferred = "EOT, Transferred to where"
        var enOtherReason = "EOT, Other reasons for no evaluation of outcome";
        var conditions = {enable: [], disable: []};
        var transferResponse = formFieldValues['EOT, Did the patient transfer out'];
        if (transferResponse == true) {
            conditions.enable.push(enTransferred);
            conditions.disable.push(enOtherReason);
        } else if (transferResponse == false) {
            conditions.disable.push(enTransferred);
            conditions.enable.push(enOtherReason);
        } else {
            conditions.disable.push(enTransferred, enOtherReason);
        }
        return conditions;
    },
    '6m PTO, 6 month post treatment outcome': function (formName, formFieldValues) {
        var conceptToEnable_dateOfDeath = "6m PTO, Date of death post treatment";
        var conceptToEnable_causeOfDeath = "6m PTO, Suspected primary cause of death";
        var conceptToEnable_reason = "6m PTO, Reasons for no post treatment followup";
        var conceptToEnable_commentsOnNoFup = "6m PTO, Comments on no post treatment followup";
        var conceptToEnable_transfer = "6m PTO, Transfer out post treatment";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['6m PTO, 6 month post treatment outcome'];
        var conceptToEnable_surgeryType = "6m PTO, Type of surgery related to post treatment death";
        var conceptToEnable_nonTBCauseOfDeath = "6m PTO, Non TB cause of post treatment death";
        if (conditionConcept == "Died post treatment") {
            conditions.enable.push(conceptToEnable_dateOfDeath, conceptToEnable_causeOfDeath);
        } else {
            conditions.disable.push(conceptToEnable_dateOfDeath, conceptToEnable_causeOfDeath, conceptToEnable_surgeryType, conceptToEnable_nonTBCauseOfDeath);
        }
        var conceptToEnable_otherReason = "6m PTO, Other reasons for no post treatment followup";
        if (conditionConcept == "LTFU post treatment") {
            conditions.enable.push(conceptToEnable_reason, conceptToEnable_commentsOnNoFup);
        } else {
            conditions.disable.push(conceptToEnable_reason, conceptToEnable_commentsOnNoFup, conceptToEnable_otherReason)
        }
        var conceptToEnable_onYes = "6m PTO, Transferred to where post treatment";
        var conceptToEnable_onNo = "6m PTO, Other reasons for no post treatment outcome";
        if (conditionConcept == "Not Evaluated") {
            conditions.enable.push(conceptToEnable_transfer);
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
        if (conditionConcept == "Surgery related death") {
            conditions.enable.push(conceptToEnable_surgeryType)
        } else {
            conditions.disable.push(conceptToEnable_surgeryType)
        }
        if (conditionConcept == "Cause other than TB") {
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
        if (SAETerm != null) {
            if (SAETerm.indexOf("Other") != -1) {
                conditions.enable.push(conceptToEnable)
            } else {
                conditions.disable.push(conceptToEnable)
            }
        }
        return conditions;
    },
    '6m PTO, Transfer out post treatment': function (formName, formFieldValues) {
        var conceptToEnable_onYes = "6m PTO, Transferred to where post treatment";
        var conceptToEnable_onNo = "6m PTO, Other reasons for no post treatment outcome";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['6m PTO, Transfer out post treatment'];
        if (conditionConcept == true) {
            conditions.enable.push(conceptToEnable_onYes)
        } else {
            conditions.disable.push(conceptToEnable_onYes)
        }
        if (conditionConcept == false) {
            conditions.enable.push(conceptToEnable_onNo)
        } else {
            conditions.disable.push(conceptToEnable_onNo)
        }
        return conditions;
    },
    'AE Form, AE term comprehensive list': function (formName, formFieldValues) {
        var conceptToEnable = "AE Form, Other AE term";
        var conditions = {enable: [], disable: []};
        var AETerm = formFieldValues['AE Form, AE term comprehensive list'];
        if (AETerm && (AETerm == "Other" || AETerm.value == "Other")) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'AE Form, AE related test': function (formName, formFieldValues) {
        var conceptToEnable = "AE form, other related test";
        var conditions = {enable: [], disable: []};
        var AETerm = formFieldValues['AE Form, AE related test'];
        if (AETerm && (AETerm == "Other" || AETerm.value == "Other")) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'AE Form, AE related to TB drugs': function (formName, formFieldValues) {
        var conceptToEnable = "AE Form, TB drug treatment";
        var conditions = {enable: [], disable: []};
        var condtionalConcept = formFieldValues['AE Form, AE related to TB drugs'];
        if (condtionalConcept == "True") {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },

    'AE Form, Is AE an SAE': function (formName, formFieldValues) {
        var enSAENumber = "AE Form, SAE Case Number";
        var enDateOutcome = "AE Form, Date of AE Outcome";
        var enAEOutcome = "AE Form, AE outcome";
        var enMaxSeverity = "AE Form, Maximum severity of AE";
        var enRelatedTBDrugs = "AE Form, AE related to TB drugs";
        var enTBDrugTx = "AE Form, TB drug treatment";
        var enOtherCausalFact = "AE Form, Other causal factors";
        var enOtherCausalFactorsRelatedToAE = "AE Form, Other causal factors related to AE";

        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['AE Form, Is AE an SAE'];
        if (conditionConcept == true) {
            conditions.enable.push(enSAENumber);
            conditions.disable.push(enDateOutcome, enAEOutcome, enMaxSeverity, enRelatedTBDrugs, enTBDrugTx, enOtherCausalFact, enOtherCausalFactorsRelatedToAE)
        } else {
            conditions.disable.push(enSAENumber);
            conditions.enable.push(enDateOutcome, enAEOutcome, enMaxSeverity, enRelatedTBDrugs, enOtherCausalFact, enOtherCausalFactorsRelatedToAE)
        }
        return conditions;
    },
    'AE Form, Other causal factors related to AE': function (formName, formFieldValues) {
        var enNonTBDrug = "AE Form, Non TB drug of other causal factor";
        var enComorbidity = "AE Form, Comorbidity of other causal factor";
        var enOtherCausalFactors = "AE Form, Other causal factor";
        var conditions = {enable: [], disable: []};
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
    'SAE Form, Previously reported as AE': function (formName, formFieldValues) {
        var previousAE = "SAE Form, AE ID if previously reported as AE";
        var conditions = {enable: [], disable: []};
        var PreviouslyReportedAE = formFieldValues['SAE Form, Previously reported as AE'];
        if (PreviouslyReportedAE == true) {
            conditions.enable.push(previousAE)
        } else {
            conditions.disable.push(previousAE)
        }
        return conditions;
    },
    'SAE Form, SAE term comprehensive AE list': function (formName, formFieldValues) {
        var conceptToEnable = "SAE Form, Other SAE term";
        var conditions = {enable: [], disable: []};
        var SAETerm = formFieldValues['SAE Form, SAE term comprehensive AE list'];
        if (SAETerm && (SAETerm == "Other" || SAETerm.value == "Other")) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    "SAE Form, Is SAE related to TB drugs": function (formName, formFieldValues) {
        var conceptToEnable = "SAE Form, TB drug treatment";
        var conditions = {enable: [], disable: []};
        var SAEIsTbDrug = formFieldValues['SAE Form, Is SAE related to TB drugs'];
        if (SAEIsTbDrug == true) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },

    'SAE Form, Related test': function (formName, formFieldValues) {
        var conceptToEnable = "SAE form, other related test";
        var conditions = {enable: [], disable: []};
        var SAETerm = formFieldValues['SAE Form, Related test'];
        if (SAETerm && (SAETerm == "Other" || SAETerm.value == "Other")) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'SAE Form, Other causal factors related to SAE': function (formName, formFieldValues) {
        var enNonTBDrug = "SAE Form, Non TB drug of other causal factors";
        var enComorbidity = "SAE Form, Comorbidity of other causal factors";
        var enOtherCausalFactors = "SAE Form, Other causal factor";
        var conditions = {enable: [], disable: []};
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
        if (conditionConcept == "Partner") {
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
        if (conditionConcept == true) {
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
        if (conditionConcept == true) {
            conditions.enable.push(conceptToEnable_true)
        } else {
            conditions.disable.push(conceptToEnable_true)
        }
        if (conditionConcept == false) {
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
        if (conditionConcept == false) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'Treatment Facility Name': function (formName, formFieldValues) {
        var conceptToEnable = "Other treatment facility name";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Treatment Facility Name'];
        if (conditionConcept == "Other") {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'HDS, Reason for hospitalization': function causeOfDeathLogics(formName, formFieldValues) {
        var conceptEnOther = "HDS, Other reason for hospitalization";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['HDS, Reason for hospitalization'];
        if (conditionConcept == "Other") {
            conditions.enable.push(conceptEnOther)
        } else {
            conditions.disable.push(conceptEnOther)
        }
        return conditions;
    },
    'HDS, New AE Reported': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['HDS, New AE Reported'];
        var conceptToEnable = "HDS, New AE ID number";
        var conceptEnSAE = "HDS, New SAE reported";
        var conceptSAERefNum = "HDS, New SAE Case number";
        if (conditionConcept != null) {
            if (conditionConcept == true) {
                conditions.enable.push(conceptToEnable, conceptEnSAE, conceptSAERefNum)
            } else {
                conditions.disable.push(conceptToEnable, conceptEnSAE, conceptSAERefNum)
            }
        } else {
            conditions.disable.push(conceptToEnable, conceptEnSAE, conceptSAERefNum)
        }
        return conditions;
    },
    'HDS, New SAE reported': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['HDS, New SAE reported'];
        var conceptToEnable = "HDS, New SAE Case number";
        if (conditionConcept == true) {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'HDS, Hospital name': function (formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['HDS, Hospital name'];
        var conceptToEnable = "HDS, Other hospital name";
        if (conditionConcept == "Other") {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'HDS, TB related surgery while hospitalization': function causeOfDeathLogics(formName, formFieldValues) {
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['HDS, TB related surgery while hospitalization'];
        if (conditionConcept == true) {
            conditions.enable.push("HDS, TB related surgery date", "HDS, Type of TB related surgery", "HDS, Side of TB related surgery", "HDS, Indication of TB related surgery");
        } else {
            conditions.disable.push("HDS, TB related surgery date", "HDS, Type of TB related surgery", "HDS, Side of TB related surgery", "HDS, Indication of TB related surgery")
        }
        return conditions;
    },
    'HDS, Type of TB related surgery': function causeOfDeathLogics(formName, formFieldValues) {
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
        if (conditionConcept == "Other") {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'Xray, Extent of disease': function (formName, formFieldValues) {
        var conceptEnCavity = "Xray, Maximum cavity size";
        var conceptEnFibrosis = "Xray, Fibrosis";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Xray, Extent of disease'];
        if (conditionConcept == "Normal" || !conditionConcept) {
            conditions.disable.push(conceptEnCavity, conceptEnFibrosis)
        } else {
            conditions.enable.push(conceptEnCavity, conceptEnFibrosis)
        }
        return conditions;
    },
    'Audiometry, Type of visit': function (formName, formFieldValues) {
        var conceptToEnable = "Audiometry, Month of scheduled visit";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Audiometry, Type of visit'];
        if (conditionConcept == "Scheduled monthly visit") {
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
        if (conditionConcept == "True") {
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
        if (conditionConcept == "Scheduled monthly visit") {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'EKG, Rhythm': function causeOfDeathLogics(formName, formFieldValues) {
        var conceptToEnable = "EKG, Other Rhythm";
        var conditions = {enable: [], disable: []};
        var SAETerm = formFieldValues['EKG, Rhythm'];
        if (SAETerm == "Other") {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'EKG, Reporting ECG Related AE': function causeOfDeathLogics(formName, formFieldValues) {
        var conceptToEnable = "EKG, AE ID Number";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['EKG, Reporting ECG Related AE'];
        if (conditionConcept == "True") {
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
        if (conditionConcept == "Other") {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'MTC, Principal reason for treatment incomplete': function (formName, formFieldValues) {
        var programRelated = "MTC, Detailed program related reason";
        var medicalRelated = "MTC, Detailed medical related reason";
        var patientRelated = "MTC, Detailed patient related reason";
        var otherRelated = "MTC, Other reason for treatment incomplete";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['MTC, Principal reason for treatment incomplete'];
        if (conditionConcept == "Program related") {
            conditions.enable.push(programRelated)
            conditions.disable.push(medicalRelated, patientRelated, otherRelated)
        } else if (conditionConcept == "Medical or treatment related") {
            conditions.enable.push(medicalRelated)
            conditions.disable.push(programRelated, patientRelated, otherRelated)
        } else if (conditionConcept == "Patient related") {
            conditions.enable.push(patientRelated)
            conditions.disable.push(programRelated, medicalRelated, otherRelated)
        } else if (conditionConcept == "Other") {
            conditions.enable.push(otherRelated)
            conditions.disable.push(programRelated, medicalRelated, patientRelated)
        } else {
            conditions.disable.push(programRelated, medicalRelated, patientRelated, otherRelated)
        }
        return conditions;
    },
    'MTC, Additional contributing reasons for less than 100% completeness': function (formName, formFieldValues) {
        var programRelated = "MTC, Additional contributing program related reasons";
        var medicalRelated = "MTC, Additional contributing medical or treatment related reasons";
        var patientRelated = "MTC, Additional contributing patient related reasons";
        var otherRelated = "MTC, Other contributing reason for treatment incomplete";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['MTC, Additional contributing reasons for less than 100% completeness'];
        if (conditionConcept && conditionConcept.indexOf("Program related") > -1) {
            conditions.enable.push(programRelated)
        } else {
            conditions.disable.push(programRelated)
        }
        if (conditionConcept && conditionConcept.indexOf("Medical or treatment related") > -1) {
            conditions.enable.push(medicalRelated)
        } else {
            conditions.disable.push(medicalRelated)
        }
        if (conditionConcept && conditionConcept.indexOf("Patient related") > -1) {
            conditions.enable.push(patientRelated)
        } else {
            conditions.disable.push(patientRelated)
        }
        if (conditionConcept && conditionConcept.indexOf("Other") > -1) {
            conditions.enable.push(otherRelated)
        } else {
            conditions.disable.push(otherRelated)
        }
        return conditions;
    },
    'Performance Status, Type of visit': function causeOfDeathLogics(formName, formFieldValues) {
        var conceptToEnable = "Performance Status, Month of scheduled visit";
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Performance Status, Type of visit'];
        if (conditionConcept == "Scheduled monthly visit") {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'Bacteriology, Xpert MTB result': function (formName, formFieldValues) {
        var burdenconceptToEnable = "Bacteriology, MTB Burden";
        var rifconceptToEnable = "Bacteriology, RIF resistance result type"
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Bacteriology, Xpert MTB result'];
        if (conditionConcept == "Detected") {
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
        var aminoglycosideconceptToEnable = "Bacteriology, MTBDRsl injectable"
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Bacteriology, HAIN MTBDRsl test result'];
        if (conditionConcept == "Detected") {
            conditions.enable.push(fluoroquinoloneconceptToEnable)
            conditions.enable.push(aminoglycosideconceptToEnable)
        } else {
            conditions.disable.push(fluoroquinoloneconceptToEnable)
            conditions.disable.push(aminoglycosideconceptToEnable)
        }
        return conditions;
    },
    'Bacteriology, Type of culture medium': function (formName, formFieldValues) {
        var otherCultureconceptToEnable = "Bacteriology, Other culture medium"
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Bacteriology, Type of culture medium'];
        if (conditionConcept == "Other") {
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
        if (conditionConcept == "Positive for M. tuberculosis") {
            conditions.enable.push(cultureColonyconceptToEnable)
        } else {
            conditions.disable.push(cultureColonyconceptToEnable)
        }
        return conditions;
    },
    'Bacteriology, Type of media for DST': function (formName, formFieldValues) {
        var cultureColonyconceptToEnable = "Bacteriology, Other type of media for DST"
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Bacteriology, Type of media for DST'];
        if (conditionConcept == "Other") {
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
        if (conditionConcept == "Other") {
            conditions.enable.push(conceptToEnable)
        } else {
            conditions.disable.push(conceptToEnable)
        }
        return conditions;
    },
    'Bacteriology, HAIN MTBDRplus test result': function (formName, formFieldValues) {
        var conceptToEnable_isoniazid = "Bacteriology, Isoniazid"
        var conceptToEnable_rifampicin = "Bacteriology, Rifampicin"
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Bacteriology, HAIN MTBDRplus test result'];
        if (conditionConcept == "Detected") {
            conditions.enable.push(conceptToEnable_isoniazid)
            conditions.enable.push(conceptToEnable_rifampicin)
        } else {
            conditions.disable.push(conceptToEnable_isoniazid)
            conditions.disable.push(conceptToEnable_rifampicin)
        }
        return conditions;
    },
    'Baseline, Start date of past TB treatment': function (formName, formFieldValues) {
        var conceptToEnable = ["Baseline, End date of past TB treatment", "Baseline, Type of past TB treatment", "Baseline, Past TB treatment regimen type", "Baseline, Past TB treatment drug regimen", "Baseline, Registration number of past TB treatment", "Baseline, Past TB treatment outcome", "Baseline, Place treatment started"];
        var conditions = {enable: [], disable: []};
        var conditionConcept = formFieldValues['Baseline, Start date of past TB treatment'];
        if (conditionConcept) {
            conditions.enable = conceptToEnable
        } else {
            conditions.disable = conceptToEnable
        }
        return conditions;
    },
    "Medication Stop Reason": function (drugOrder, conceptName) {
        if (conceptName == "Adverse event" || conceptName == "Other") {
            drugOrder.orderReasonNotesEnabled = true;
            return true;
        }
        else
            return false;
    }

};
