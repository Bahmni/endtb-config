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
            "Baseline, Chronic obstructive pulmonary disease", "Baseline, Has cancer",
            "Baseline, Heart or atherosclerotic disease", "Baseline, Hepatitis B", "Baseline, Hepatitis C", "Baseline, Depression",
            "Baseline, Has other psychiatric illness", "Baseline, Psychiatric illness type", "Baseline, Seizure disorder","Baseline, Pre-existing neuropathy", 
	    "Baseline, Other pre-existing disease"];
        $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/coMorbidities.html";
        var allComorbidityConceptNames = [];
        spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, undefined, undefined, $scope.visitUuid, undefined, null, $scope.enrollment).then(function (response) {
            var observations = _.filter(response.data, function(obs){
              return obs.value.name === "True" ;
            });
            _.each(observations, function(obs){
                allComorbidityConceptNames.push(obs.conceptNameToDisplay);
            });
            var freeTextObservations = _.filter(response.data, function(obs){
              return obs.concept.dataType === "Text";
            });
            _.each(freeTextObservations, function(obs){
                allComorbidityConceptNames.push(obs.valueAsString);
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
}]);
