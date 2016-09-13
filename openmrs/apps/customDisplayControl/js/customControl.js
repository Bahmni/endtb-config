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
    var link = function ($scope) {
        var conceptNames = ["Diabetes Mellitus","Baseline, Chronic renal insufficiency","History of liver cirrhosis",
            "Baseline, Chronic obstructive pulmonary disease", "Baseline, Has cancer","Baseline, Cancer type",
            "Baseline, Heart or atherosclerotic disease", "Baseline, Type of heart disease","Baseline, Hepatitis B", "Baseline, Hepatitis C", "Baseline, Depression",
            "Baseline, Has other psychiatric illness", "Baseline, Psychiatric illness type","Baseline, Seizure disorder","Baseline, Pre-existing neuropathy","Baseline, Other pre-existing disease"];
        $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/coMorbidities.html";
        var allComorbidityConceptNames = [];
        var conceptNameWithFreeTextFields = ["Baseline, Has cancer","Baseline, Cancer type",
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

            var addCodedObs = function(obs){
                if(obs.value.name === "True"){
                    var displayString = obs.conceptNameToDisplay;
                    if(isCodedObsWithFreeText(obs)) {
                        displayString = getStringToDisplay(obs);
                    }
                    allComorbidityConceptNames.push(displayString);
                }
            };

            _.each(response.data, function (obs) {
                if(isFreeTextWithoutCodedObs(obs)){
                    allComorbidityConceptNames.push(obs.valueAsString);
                }
                addCodedObs(obs);
            });

            $scope.allComorbidities = allComorbidityConceptNames.join(", ");
            $scope.hasNoValue = _.isEmpty(allComorbidityConceptNames);
        }));
    };

    return {
        restrict: 'E',
        link: link,
        template: '<ng-include src="contentUrl"/>'
    }
}]).directive('patientMonitoringTool', ['$http', '$translate', 'spinner', '$q', 'appService',
    function ($http, $translate, spinner, $q, appService) {
        var link = function ($scope) {

            var getPatientObservationChartData = function () {

                return fetchPatientMonitoringChartData('/openmrs/ws/rest/v1/endtb/patientFlowsheet', $scope.patient.uuid, $scope.enrollment).success(function (data) {
                    $scope.flowsheetHeader = data.flowsheetHeader;
                    $scope.flowsheetData = data.flowsheetData;
                    $scope.highlightedColumnIndex = data.flowsheetHeader.indexOf(data.currentMilestoneName);
                })
            };

            var fetchPatientMonitoringChartData = function(url, patientUuid, programUuid) {
                return $http.get(url, {
                    params: {patientUuid: patientUuid, programUuid: programUuid},
                    withCredentials: true
                });
            };

            var init = function () {
                return $q.all([getPatientObservationChartData()]).then(function () {
                });
            };
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/patientMonitoringTool.html";

            spinner.forPromise(init());
        };
        return {
            restrict: 'E',
            link: link,
            scope: {
                section: "=",
                patient: "=",
                enrollment: "@"
            },
            template: '<ng-include src="contentUrl"/>'
        };
    }]);;
