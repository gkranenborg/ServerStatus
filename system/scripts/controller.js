var systemApp = angular.module("systemApp",[]);

// The SystemCtrl controller controls the first 2 tables on the index.htm page showing the Disk Space and DB information only.

systemApp.controller('SystemCtrl',['$scope', 'ServicesFactory', 'DiskFactory', 'DBFactory', 'CustomerNameFactory', 'DateTimeFactory', function ($scope, ServicesFactory, DiskFactory, DBFactory, CustomerNameFactory,DateTimeFactory, ENV) {
	
// Set all variables and arrays used by this controller.
	
	$scope.system = [];
	$scope.database = [];
	$scope.services = [];
	$scope.customer =null;
	$scope.datetime = null;
	var initialized = false;
	
// Set the class for conditional cell formatting showing the Disk Space information.	

	$scope.getDiskClass = function(disk) {
		if ( disk <= 10) { return 'settings.alarm'} else
			if (disk <= 25) { return 'settings.warning'}
    };
	$scope.settings = {	alarm: "Red", warning: "Orange" };
	
	CustomerNameFactory.list( function(data) {
		$scope.customer = data[0];
	});
	
// Read the JSON file containing the timestamp information for the Disk and DB table updates.
	
	   function GetIntervalInfo() { 
	       DateTimeFactory.list( function(data) {
	        $scope.datetime = data[0];
	       });
	       DBFactory.list( function(data) {
	           $scope.database = data;
	       });
	       DiskFactory.list( function(data) {
	           $scope.system = data; 
	       });
	       ServicesFactory.list( function(data) {
	           $scope.services = data;
	       });
	       if ( initialized ) {
	           $scope.$apply();
	          }
	       initialized = true;
	   };
	   
	  GetIntervalInfo();
	  var setGetIntervalInfo = setInterval(GetIntervalInfo, 300000);
	   
}]);

// The BOPcordysCtrl controller controls the drop down box showing the BOP organizations, and the table showing the Service Container Status.

systemApp.controller('BOPcordysCtrl', ['$scope', 'DefaultOrgFactory' , 'SOAPFactory', 'LegendFactory', 'HostnameFactory' ,
    function($scope,DefaultOrgFactory,SOAPFactory,LegendFactory,HostnameFactory) {
	
        $scope.organizations=[];
        $scope.orgcontainers=[];
        $scope.allorgprocesses=[];
        $scope.listcontainers=[];
        $scope.cordyssc=[];
        $scope.legend=[];
        $scope.orderByField = 'cn';
        $scope.reverseSort = false;
        $scope.boporg=null;
        $scope.hname=null;
        
// This factory determines the default organization and calls the Web Service to create a list of all organizations.        
        
    	DefaultOrgFactory.list( function(data) {
    		$scope.boporg=data[0];
    		$scope.selectedItem = $scope.boporg.description;
    		$scope.selectedOrg = $scope.boporg.description;
    		var splitarray = $scope.boporg.dn.split(",");
    		var newarray = splitarray.splice(1,3);
    		var newstring = newarray.join();
            SOAPFactory.getOrganizations(newstring,$scope.fetchOrganizations);
    	});
        
// This section fetches the drop down box for the organizations.
        
        $scope.fetchOrganizations= function(data){
        	var allOrg= [{description : 'All'}];
            $scope.organizations=SOAPFactory.parseOrganizations(data);
            $scope.displayOrganizations=allOrg.concat($scope.organizations);
            SOAPFactory.getSoapProcessors($scope.boporg.dn,$scope.fetchSoapProcessors);
        }
        
// This section fetches the data for all Service Containers per organization.
        
        $scope.fetchSoapProcessors= function(data){
            var myorgcontainers=SOAPFactory.parseSoapProcessors(data);
            $scope.orgcontainers= $scope.orgcontainers.concat(myorgcontainers);
            SOAPFactory.List("Active",$scope.fetchList);
        }
        
        $scope.fetchProcessInstancesData= function(data){
            $scope.allorgprocesses=SOAPFactory.parseProcessInstances(data);
        }
        
// This section fetches the data for all active Service Containers.
        
        $scope.fetchList= function(data){
            $scope.listcontainers=SOAPFactory.parseList(data);
            $scope.cordyssc=SOAPFactory.findServiceEntry($scope.orgcontainers,$scope.listcontainers);
        }       
        
// This function determines the background color of the table cell containing the Service Container name (dn) based on it's Status and Automatic Start type.
		
		$scope.getSoapClass = function(status, start) {
			if ( start == "true" ) {
				switch (status) {
				case 'Stopped':
				case 'Configuration Error':
				case 'Connection Error':
					return 'settings.alarm';
				case 'Starting':
					return 'settings.warning';
				}
			}
	    };
		$scope.settings = {	alarm: "Red", warning: "Orange" };
	    
// This function gets triggered when the drop down box is used to select another organization. It will then request all Soap Containers for this organization from BOP and update the table.
		
        $scope.ChangeSoap=function (selectedItem) {
        	$scope.orgcontainers=[];
        	if (selectedItem != "All") {
				for (s = 0; s < $scope.organizations.length; s++)
				{
					if ($scope.organizations[s].description == selectedItem) {
						$scope.boporg.dn=$scope.organizations[s].dn;
						SOAPFactory.getSoapProcessors($scope.boporg.dn,$scope.fetchSoapProcessors);
						};
				};
        	} else {
        		for (u = 0; u < $scope.organizations.length; u++)
        		{
        			$scope.boporg.dn=$scope.organizations[u].dn;
         			SOAPFactory.getSoapProcessors($scope.boporg.dn,$scope.fetchSoapProcessors);
        		};
        	};
        };
        
// This function creates the BPM Instance overview based on the selected organization.        
        
        
        $scope.SelectBPM = function (selectedOrg){
            for (v = 0; v < $scope.organizations.length; v++)
            {
                if ($scope.organizations[v].description == selectedOrg) {
                    $scope.boporg.dn=$scope.organizations[v].dn;
                    SOAPFactory.getProcessInstances($scope.boporg.dn,$scope.fetchProcessInstancesData);
                    };
            };
        };
          
// This function is the general function to send the SOAP call to the BOP backend.        
        
        $scope.WebGateWay = function() {
        	HostnameFactory.list( function(data) {
        		$scope.hname = data[0];
            	$scope.url=SOAPFactory.getWebGatewayurl($scope.hname.hostname);
        	});
        };
        
        $scope.WebGateWayHealth = function() {
            HostnameFactory.list( function(data) {
                $scope.hname = data[0];
                $scope.url=SOAPFactory.getWebGatewayHealthurl($scope.hname.hostname);
            });
        };
        
        $scope.BPMDashBoard = function() {
                $scope.url='bpmdashboard.htm';
        };
        
// This function created a Web Page Legend list.        
        
    	LegendFactory.list( function(data) {
    		$scope.legend = data;
    	});
    	
// This function sets the background color for the Web Page Legend table per cell.   	
    	
    	$scope.getLegendClass = function(item) {
    		if ( item == 'Red') { return 'settings.alarm'} else
    			if (item == 'Orange') { return 'settings.warning'}
            };
    	$scope.settings = {	alarm: "Red", warning: "Orange" };

}]);