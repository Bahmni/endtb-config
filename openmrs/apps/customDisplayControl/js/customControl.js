'use strict';

angular.module('bahmni.common.displaycontrol.custom')
    .directive('birthCertificate', ['observationsService', 'appService', 'spinner', function (observationsService, appService, spinner) {
        var link = function ($scope) {
            console.log("inside birth certificate");
            var conceptNames = ["HEIGHT"];
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/birthCertificate.html";
            spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                $scope.observations = response.data;
            }));
        };

        return {
            restrict: 'E',
            template: '<ng-include src="contentUrl"/>',
            link: link
        }
    }]).directive('deathCertificate', ['observationsService', 'appService', 'spinner', function (observationsService, appService, spinner) {
    var link = function ($scope) {
        var conceptNames = ["WEIGHT"];
        $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/deathCertificate.html";
        spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
            $scope.observations = response.data;
        }));
    };

    return {
        restrict: 'E',
        link: link,
        template: '<ng-include src="contentUrl"/>'
    }
}]).directive('coMorbidities', ['observationsService', 'appService', 'spinner', function (observationsService, appService, spinner) {
    var link = function ($scope, element) {
        var conceptNames = ["Diabetes Mellitus", "Baseline, Chronic renal insufficiency", "History of liver cirrhosis",
            "Baseline, Chronic obstructive pulmonary disease", "Baseline, Has cancer", "Baseline, Cancer type",
            "Baseline, Heart or atherosclerotic disease", "Baseline, Type of heart disease", "Baseline, Hepatitis B", "Baseline, Hepatitis C", "Baseline, Depression",
            "Baseline, Has other psychiatric illness", "Baseline, Psychiatric illness type", "Baseline, Seizure disorder", "Baseline, Pre-existing neuropathy", "Baseline, Other pre-existing disease"];
        $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/coMorbidities.html";
        var allComorbidityConceptNames = [];
        var conceptNameWithFreeTextFields = ["Baseline, Has cancer", "Baseline, Cancer type",
            "Baseline, Has other psychiatric illness", "Baseline, Psychiatric illness type", "Baseline, Heart or atherosclerotic disease", "Baseline, Type of heart disease"];

        spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, undefined, undefined, $scope.visitUuid, undefined, null, $scope.enrollment).then(function (response) {

            var isFreeTextWithoutCodedObs = function (obs) {
                return obs.concept.dataType === "Text" && conceptNameWithFreeTextFields.indexOf(obs.concept.name) === -1;
            };

            var isCodedObsWithFreeText = function (obs) {
                return conceptNameWithFreeTextFields.indexOf(obs.concept.name) >= 0;
            };

            var getStringToDisplay = function (obs) {
                var stringToDisplay = obs.conceptNameToDisplay;
                var freeTextField = _.find(response.data, function (freeText) {
                    return freeText.obsGroupUuid === obs.obsGroupUuid && freeText.concept.dataType === "Text";
                });
                if (!(freeTextField === undefined)) {
                    stringToDisplay = stringToDisplay + ' (' + freeTextField.valueAsString + ')';
                }
                return stringToDisplay;
            };

            var addCodedObs = function (obs) {
                if (obs.value.name === "True") {
                    var displayString = obs.conceptNameToDisplay;
                    if (isCodedObsWithFreeText(obs)) {
                        displayString = getStringToDisplay(obs);
                    }
                    allComorbidityConceptNames.push(displayString);
                }
            };

            _.each(response.data, function (obs) {
                if (isFreeTextWithoutCodedObs(obs)) {
                    allComorbidityConceptNames.push(obs.valueAsString);
                }
                addCodedObs(obs);
            });

            $scope.allComorbidities = allComorbidityConceptNames.join(", ");
            $scope.hasNoValue = _.isEmpty(allComorbidityConceptNames);
        }), element);
    };

    return {
        restrict: 'E',
        link: link,
        template: '<ng-include src="contentUrl"/>'
    }
}]).directive('patientMonitoringTool', ['$http', '$translate', 'spinner', '$q', 'appService', 'messagingService', 'observationsService',
    function ($http, $translate, spinner, $q, appService, messagingService, observationsService) {
        var link = function ($scope, element) {
            var fetchFlowsheetAttributes = function (patientProgramUuid) {
                return $http.get('/openmrs/ws/rest/v1/endtb/patientFlowsheetAttributes', {
                    params: {patientProgramUuid: patientProgramUuid},
                    withCredentials: true
                });
            };

            var getAllDrugOrdersFor = function (patientUuid, conceptSetToBeIncluded, conceptSetToBeExcluded, isActive, patientProgramUuid, $q) {
                var deferred = $q.defer();
                var params = {patientUuid: patientUuid};
                if (conceptSetToBeIncluded) {
                    params.includeConceptSet = conceptSetToBeIncluded;
                }
                if (conceptSetToBeExcluded) {
                    params.excludeConceptSet = conceptSetToBeExcluded;
                }
                if (isActive !== undefined) {
                    params.isActive = isActive;
                }
                if (patientProgramUuid) {
                    params.patientProgramUuid = patientProgramUuid;
                }

                $http.get(Bahmni.Common.Constants.bahmniDrugOrderUrl + "/drugOrderDetails", {
                    params: params,
                    withCredentials: true
                }).success(function (response) {
                    deferred.resolve(response);
                });
                return deferred.promise;
            };


            var getPatientObservationChartData = function (startDate, stopDate) {
                return fetchPatientMonitoringChartData('/openmrs/ws/rest/v1/endtb/patientFlowsheet', $scope.enrollment, startDate, stopDate).success(function (data) {
                    $scope.flowsheetHeader = data.milestones || [];
                    $scope.flowsheetData = data.flowsheetData;
                    $scope.flowsheetConfig = data.flowsheetConfig;
                    
                    if (startDate == null) {
                        messagingService.showMessage("error", "Start date missing. Cannot display monitoring schedule");
                    }
                    //Highlighted Current Month
                    if (data.highlightedCurrentMilestone != null && data.highlightedCurrentMilestone != "") {
                        var highlightedCurrentMilestone = _.find($scope.flowsheetHeader, function(header) {
                            return header.name.indexOf(data.highlightedCurrentMilestone) !== -1;
                        });
                        $scope.highlightedCurrentColumnIndex = $scope.flowsheetHeader.indexOf(highlightedCurrentMilestone);
                    }
                    
                    $scope.treatmentStopped = stopDate ? true : false;
                    
                  //Treatment End Milestone
                    if ($scope.treatmentStopped ) {
                        var treatmentEndMilestone = _.find($scope.flowsheetHeader, function(header) {
                            return header.name.indexOf(data.endDateMilestone) !== -1;
                        });
                        $scope.treatmentEndColumnIndex = $scope.flowsheetHeader.indexOf(treatmentEndMilestone );
                    }
                    
                })
            };

            var fetchPatientMonitoringChartData = function(url, patientProgramUuid, startDate, stopDate) {
                return $http.get(url, {
                    params: {patientProgramUuid: patientProgramUuid, startDate: startDate, stopDate: stopDate},
                    withCredentials: true
                });
            };

            var getPatientAttributes = function () {
                return fetchFlowsheetAttributes($scope.enrollment).success(function (data) {
                    $scope.treatmentRegNum = data.treatmentRegistrationNumber;
                    $scope.reportDate = new Date();
                    $scope.patientEMRID = data.patientEMRID;
                    $scope.drugStartDate = data.newDrugTreatmentStartDate;
                    $scope.mdrtbTreatementStartDate = data.mdrtbTreatmentStartDate;
                    $scope.consentForEndtbStudy = data.consentForEndtbStudy;
                    $scope.baselineXRayStatus = data.baselineXRayStatus;
                    $scope.hivStatus = data.hivStatus;

                    if ($scope.drugStartDate != null) {
                        $scope.currentMonthOfNewDrugTreatment = Bahmni.Common.Util.DateUtil.diffInDays($scope.drugStartDate - $scope.reportDate) / 30.5;
                    }

                    if ($scope.mdrtbTreatementStartDate != null) {
                        $scope.currentMonthOfMDRTBTreatment = Bahmni.Common.Util.DateUtil.diffInDays($scope.mdrtbTreatementStartDate - $scope.reportDate) / 30.5;
                    }
                });
            };

            var getActiveTBDrugOrders = function () {
                return getAllDrugOrdersFor($scope.patient.uuid, "All TB Drugs", null, true, $scope.enrollment, $q).then(function (responseData) {
                    $scope.activeTBRegimen = _.map(responseData, function (data) {
                        return _.find(data.concept.mappings, function (mapping) {
                            return mapping.source === "Abbreviation";
                        }).code;
                    }).join("-");
                });
            };

            var getStartDateForDrugConcepts = function (patientProgramUuid, drugConcepts) {
                return $http.get('/openmrs/ws/rest/v1/endtb/startDateForDrugs', {
                    params: {patientProgramUuid: patientProgramUuid, drugConcepts: drugConcepts},
                    withCredentials: true
                })
            };

            var getDateValueForAObsConcept = function (patientProgramUuid, conceptName) {
                return observationsService.fetchForPatientProgram(patientProgramUuid, [conceptName]).then(function (response) {
                    if(response.data.length != 0) {
                        return response.data[0].value;
                    } else {
                        return null;
                    }
                });
            };

            var getStartDateForFlowsheet = function () {
                var startDateObsConcept = $scope.config.startDateObsConcept;
                var startDateDrugConcepts = $scope.config.startDateDrugConcepts;
                var patientProgramUuid = $scope.enrollment;
                if(startDateObsConcept && startDateDrugConcepts) {
                    return $q.when("Both start date obs and drug concepts are configured");
                } else if(startDateObsConcept) {
                    return getDateValueForAObsConcept(patientProgramUuid, startDateObsConcept);
                } else if(startDateDrugConcepts) {
                    return getStartDateForDrugConcepts(patientProgramUuid, startDateDrugConcepts).then(function (response) {
                        //return moment(response.data).format("YYYY-MM-DD");
                        return response.data ? moment(response.data).format("YYYY-MM-DD") : null;
                    });
                } else {
                    return $q.when("No concept given for start Date");
                }
            };

            var init = function () {
                return $q.all([getStartDateForFlowsheet(), getDateValueForAObsConcept($scope.enrollment, $scope.config.endDateConcept), getPatientAttributes(), getActiveTBDrugOrders()]).then(function (results) {
                    return getPatientObservationChartData(results[0], results[1]);
                });
            };
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/patientMonitoringTool.html";

            spinner.forPromise(init(), element);
        };
        return {
            restrict: 'E',
            link: link,
            template: '<ng-include src="contentUrl"/>'
        };
    }]);
