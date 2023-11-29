'use strict';

angular.module('bahmni.common.displaycontrol.custom')
    .directive('deathCertificate', ['$q','observationsService','visitService', 'bedService','appService', 'spinner','$sce', function ($q,observationsService, visitService, bedService,appService, spinner, $sce)
    {
        var link = function ($scope) 
        {
            
            var conceptNames = ["Death Note"];
            spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                    $scope.observations = response.data[0];
                    

                }));
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/deathCertificatehindi.html";
            $scope.curDate=new Date();
            
            spinner.forPromise($q.all([bedService.getAssignedBedForPatient($scope.patient.uuid),visitService.getVisitSummary($scope.visitUuid)]).then(function(results){
                    $scope.bedDetails = results[0];
                    $scope.visitSummary = results[1].data;
                }));
                
        };
        var controller = function($scope){
        	$scope.htmlLabel = function(label){
        		return $sce.trustAsHtml(label)
        	}
        }
        return {
            restrict: 'E',
            link: link,
            controller : controller,
            template: '<ng-include src="contentUrl"/>'
        }
    }]).directive('rntcpForm', ['$q','observationsService','visitService', 'bedService','appService', 'spinner','$sce', function ($q,observationsService, visitService, bedService,appService, spinner, $sce) 
    {
        var link = function ($scope) 
        {
            
            var conceptNames = ["RNTCP Form"];
            spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                    $scope.observations = response.data[0];   
                    $scope.rntcpform = []
                    function createForm(obs) {
                        if ($scope.observations==undefined)
                        { 
                            console.log("template not filled");
                        }
                         else
                        {
                           if (obs.groupMembers.length == 0){
                              if ($scope.rntcpform[obs.conceptNameToDisplay] == undefined){
                                 $scope.rntcpform[obs.conceptNameToDisplay] = obs.valueAsString;
                              }
                              else{
                                 $scope.rntcpform[obs.conceptNameToDisplay] = $scope.rntcpform[obs.conceptNameToDisplay] + ' ' + obs.valueAsString;                                
                              }

                              if(obs.comment != null){
                                $scope.rntcpform[obs.conceptNameToDisplay] = $scope.rntcpform[obs.conceptNameToDisplay] + ' ' + obs.comment;
                              }   
                           }
                           else{
                              for(var i = 0; i < obs.groupMembers.length; i++) { 
                                   createForm(obs.groupMembers[i]);
                              }
                              
                           }

                        }
                    }
                    createForm(response.data[0]);

                }));
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/rntcpform.html";
            $scope.curDate=new Date();
            
            spinner.forPromise($q.all([bedService.getAssignedBedForPatient($scope.patient.uuid),visitService.getVisitSummary($scope.visitUuid)]).then(function(results){
                    $scope.bedDetails = results[0];
                    $scope.visitSummary = results[1].data;
                }));
                
        };
        var controller = function($scope){
        	$scope.htmlLabel = function(label){
        		return $sce.trustAsHtml(label)
        	}
        }
        return {
            restrict: 'E',
            link: link,
            controller : controller,
            template: '<ng-include src="contentUrl"/>'
        }
    }]).directive('clinicalinfoTb', ['$q','observationsService','visitService', 'bedService','appService', 'spinner','$sce', function ($q,observationsService, visitService, bedService,appService, spinner, $sce) 
    {
        var link = function ($scope) 
        {
            
            var conceptNames = ["RMRCT Form"];
            spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                    $scope.observations = response.data[0];
                    $scope.rmrctForm = [];
                    function createForm(obs) {
                    if ($scope.observations==undefined)
                      { 
                            console.log("template not filled");
                       }
                       else
                      {
                           if (obs.groupMembers.length == 0){
                              if ($scope.rmrctForm[obs.conceptNameToDisplay] == undefined){
                                 $scope.rmrctForm[obs.conceptNameToDisplay] = obs.valueAsString;
                              }
                              else{
                                 $scope.rmrctForm[obs.conceptNameToDisplay] = $scope.rmrctForm[obs.conceptNameToDisplay] + ' ' + obs.valueAsString;                                
                              }

                              if(obs.comment != null){
                                $scope.rmrctForm[obs.conceptNameToDisplay] = $scope.rmrctForm[obs.conceptNameToDisplay] + ' ' + obs.comment;
                              }   
                           }
                           else{
                              for(var i = 0; i < obs.groupMembers.length; i++) { 
                                   createForm(obs.groupMembers[i]);
                              }
                              
                           }
                       }
                    }

                    createForm(response.data[0]);

                }));
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/clinicalinfotb.html";
            $scope.curDate=new Date();
            
            spinner.forPromise($q.all([bedService.getAssignedBedForPatient($scope.patient.uuid),visitService.getVisitSummary($scope.visitUuid)]).then(function(results){
                    $scope.bedDetails = results[0];
                    $scope.visitSummary = results[1].data;
                }));
                
        };
        var controller = function($scope){
        	$scope.htmlLabel = function(label){
        		return $sce.trustAsHtml(label)
        	}
            $scope.date = new Date();
        }
        return {
            restrict: 'E',
            link: link,
            controller : controller,
            template: '<ng-include src="contentUrl"/>'
        }
    }]).directive('pplhlthSptgrp', ['$q','observationsService','visitService', 'bedService','appService', 'spinner','$sce', function ($q,observationsService, visitService, bedService,appService, spinner, $sce) 
    {
        var link = function ($scope) 
        {
            
            var conceptNames = ["People Health Support Group Form"];
            spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                    $scope.observations = response.data[0];
                    $scope.hindujaform = []
                    function createForm(obs) {
                    if ($scope.observations==undefined)
                     { 
                        console.log("template not filled");
                     }
                     else
                     {
                           if (obs.groupMembers.length == 0){
                              if ($scope.hindujaform[obs.conceptNameToDisplay] == undefined){
                                 $scope.hindujaform[obs.conceptNameToDisplay] = obs.valueAsString;
                              }
                              else{
                                 $scope.hindujaform[obs.conceptNameToDisplay] = $scope.hindujaform[obs.conceptNameToDisplay] + ' ' + obs.valueAsString;                                
                              }

                              if(obs.comment != null){
                                $scope.hindujaform[obs.conceptNameToDisplay] = $scope.hindujaform[obs.conceptNameToDisplay] + ' ' + obs.comment;
                              }   
                           }
                           else{
                              for(var i = 0; i < obs.groupMembers.length; i++) { 
                                   createForm(obs.groupMembers[i]);
                              }
                              
                           }
                        }
                    }
                    createForm(response.data[0]);

                    

                }));
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/pplhlthsptgrp.html";
            $scope.curDate=new Date();
            
            spinner.forPromise($q.all([bedService.getAssignedBedForPatient($scope.patient.uuid),visitService.getVisitSummary($scope.visitUuid)]).then(function(results){
                    $scope.bedDetails = results[0];
                    $scope.visitSummary = results[1].data;
                }));
                
        };
        var controller = function($scope){
        	$scope.htmlLabel = function(label){
        		return $sce.trustAsHtml(label)
        	}
        }
        return {
            restrict: 'E',
            link: link,
            controller : controller,
            template: '<ng-include src="contentUrl"/>'
        }
    }]).directive('referralForm', ['$q','observationsService','visitService', 'bedService','appService', 'spinner','$sce', function ($q,observationsService, visitService, bedService,appService, spinner, $sce) 
    {
        var link = function ($scope) 
        {
            
            var conceptNames = ["Referral Form"];
            spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                    $scope.observations = response.data[0];
                    $scope.referralForm = [];
                    function createForm(obs) {
                           if (obs.groupMembers.length == 0){
                              if ($scope.referralForm[obs.conceptNameToDisplay] == undefined){
                                 $scope.referralForm[obs.conceptNameToDisplay] = obs.valueAsString;
                              }
                              else{
                                 $scope.referralForm[obs.conceptNameToDisplay] = $scope.referralForm[obs.conceptNameToDisplay] + ' ' + obs.valueAsString;                                
                              }

                              if(obs.comment != null){
                                $scope.referralForm[obs.conceptNameToDisplay] = $scope.referralForm[obs.conceptNameToDisplay] + ' ' + obs.comment;
                              }   
                           }
                           else{
                              for(var i = 0; i < obs.groupMembers.length; i++) { 
                                   createForm(obs.groupMembers[i]);
                              }
                              
                           }

                    }
                    createForm(response.data[0]);

                }));
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/referralform.html";
            
                            
        };
        var controller = function($scope){
        	$scope.htmlLabel = function(label){
        		return $sce.trustAsHtml(label)
        	}
            $scope.date = new Date();
        }
        return {
            restrict: 'E',
            link: link,
            controller : controller,
            template: '<ng-include src="contentUrl"/>'
        }
    }]).directive('referraltrForm', ['$q','observationsService','visitService','appService', 'spinner','$sce', function ($q,observationsService, visitService,appService, spinner, $sce)
    {
        var link = function ($scope)
        {

            var conceptNames = ["Referral Form"];
            spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                $scope.observations = response.data[0];
                $scope.referralForm = [];

            }));
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/referraltrform.html";


        };
        var controller = function($scope){
            $scope.htmlLabel = function(label){
                return $sce.trustAsHtml(label)
            }
            $scope.date = new Date();
        }
        return {
            restrict: 'E',
            link: link,
            controller : controller,
            template: '<ng-include src="contentUrl"/>'
        }
    }]).directive('referralprForm', ['$q','observationsService','visitService','appService', 'spinner','$sce', function ($q,observationsService, visitService,appService, spinner, $sce)
    {
        var link = function ($scope)
        {

            var conceptNames = ["Referral Form"];
            spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                $scope.observations = response.data[0];
                $scope.referralForm = [];

            }));
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/referralprform.html";


        };
        var controller = function($scope){
            $scope.htmlLabel = function(label){
                return $sce.trustAsHtml(label)
            }
            $scope.date = new Date();
        }
        return {
            restrict: 'E',
            link: link,
            controller : controller,
            template: '<ng-include src="contentUrl"/>'
        }
    }]).directive('referralflForm', ['$q','observationsService','visitService','appService', 'spinner','$sce', function ($q,observationsService, visitService,appService, spinner, $sce)
    {
        var link = function ($scope)
        {

            var conceptNames = ["Referral Form"];
            spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                $scope.observations = response.data[0];
                $scope.referralForm = [];

            }));
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/referralflform.html";


        };
        var controller = function($scope){
            $scope.htmlLabel = function(label){
                return $sce.trustAsHtml(label)
            }
            $scope.date = new Date();
        }
        return {
            restrict: 'E',
            link: link,
            controller : controller,
            template: '<ng-include src="contentUrl"/>'
        }
    }]).directive('referralfmDoctor', ['observationsService', 'appService', 'spinner', function (observationsService, appService, spinner) {
        var link = function ($scope) {
            var conceptNames = ["Referral Form, Doctors Name"];
            var conceptName=["Referral Form, Health Center"];
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/referraldocname.html";
            spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                $scope.observations = response.data[0];
            }));
            spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptName, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                $scope.observation = response.data[0];
            }));

        };

        return {
            restrict: 'E',
            link: link,
            template: '<ng-include src="contentUrl"/>'
        }
    }]).directive('referralSummary', ['$q','observationsService','appService', 'spinner','$sce', function ($q,observationsService,appService, spinner, $sce)
           {
               var link = function ($scope)
               {

                   var conceptNames = ["Referral form, Summary"];
                    var conceptName=["Referral Form, Referral Follow up"];
                   spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                           $scope.observations = response.data[0];
                           $scope.refsummryForm = []
                           function createForm(obs) {
                           if ($scope.observations==undefined)
                              { 
                                   console.log("template not filled");
                               }
                            else
                               {
                                  if (obs.groupMembers.length == 0){
                                     if ($scope.refsummryForm[obs.conceptNameToDisplay] == undefined){
                                        $scope.refsummryForm[obs.conceptNameToDisplay] = obs.valueAsString;
                                     }
                                     else{
                                        $scope.refsummryForm[obs.conceptNameToDisplay] = $scope.refsummryForm[obs.conceptNameToDisplay] + ' ' + obs.valueAsString;
                                     }

                                     if(obs.comment != null){
                                       $scope.refsummryForm[obs.conceptNameToDisplay] = $scope.refsummryForm[obs.conceptNameToDisplay] + ' ' + obs.comment;
                                     }
                                  }
                                  else{
                                     for(var i = 0; i < obs.groupMembers.length; i++) {
                                          createForm(obs.groupMembers[i]);
                                     }

                                  }
                                }
                           }
                           createForm(response.data[0]);



                       }));
                     spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptName, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                                   $scope.observation = response.data[0];
                               }));

                   $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/referralSummary.html";
                   $scope.curDate=new Date();

               };
               var controller = function($scope){
               	$scope.htmlLabel = function(label){
               		return $sce.trustAsHtml(label)
               	}
               }
               return {
                   restrict: 'E',
                   link: link,
                   controller : controller,
                   template: '<ng-include src="contentUrl"/>'
               }
 }]).directive('patientAppointmentsDashboard', ['$http', '$q', '$window','appService', function ($http, $q, $window, appService) {
    var link = function ($scope) {
        $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/patientAppointmentsDashboard.html";
        var getUpcomingAppointments = function () {
            var params = {
                q: "bahmni.sqlGet.upComingAppointments",
                v: "full",
                patientUuid: $scope.patient.uuid
            };
            return $http.get('/openmrs/ws/rest/v1/bahmnicore/sql', {
                method: "GET",
                params: params,
                withCredentials: true
            });
        };
        var getPastAppointments = function () {
            var params = {
                q: "bahmni.sqlGet.pastAppointments",
                v: "full",
                patientUuid: $scope.patient.uuid
            };
            return $http.get('/openmrs/ws/rest/v1/bahmnicore/sql', {
                method: "GET",
                params: params,
                withCredentials: true
            });
        };
        $q.all([getUpcomingAppointments(), getPastAppointments()]).then(function (response) {
            $scope.upcomingAppointments = response[0].data;
            $scope.upcomingAppointmentsHeadings = _.keys($scope.upcomingAppointments[0]);
            $scope.pastAppointments = response[1].data;
            $scope.pastAppointmentsHeadings = _.keys($scope.pastAppointments[0]);
        });

        $scope.goToListView = function () {
            $window.open('/bahmni/appointments/#/home/manage/appointments/list');
        };
    };
    return {
        restrict: 'E',
        link: link,
        scope: {
            patient: "=",
            section: "="
        },
        template: '<ng-include src="contentUrl"/>'
    };
    }]);
