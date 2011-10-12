package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAProject;
	import Model.Model_ERARoom;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_UpdateERACase
	{
		private var caseID:Number;
		private var rmCode:String;
		private var title:String;
		private var researcherArray:Array;
		private var qutSchool:String;
		private var forArray:Array;
		private var categoryArray:Array;
		private var productionManagerArray:Array;
		private var productionTeamArray:Array;
		private var connection:Connection;
		private var callback:Function;
		
		private var newERACaseID:Number;
		private var roomBeingMadeIndex:Number; //the index for the room we are currently making in @see Model_ERARoom
		
		public function Transaction_UpdateERACase(caseID:Number,
												  rmCode:String, 
												  title:String,
												  researcherArray:Array,
												  qutSchool:String, 
												  forArray:Array,
												  categoryArray:Array,
												  productionManagerArray:Array,
												  productionTeamArray:Array,
												  connection:Connection, 
												  callback:Function)
		{
			this.caseID = caseID;	
			this.rmCode = rmCode;
			this.title = title;
			this.researcherArray = researcherArray;
			this.qutSchool = qutSchool;
			this.forArray = forArray;
			this.categoryArray = categoryArray;
			this.productionManagerArray = productionManagerArray;
			this.productionTeamArray = productionTeamArray;
			this.connection = connection;
			this.callback = callback;
			
			updateERACase();
		}
		
		private function updateERACase():void {
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;

			argsXML.id = caseID;
			
			//			// Set this as a collection (cause we are going to put the case elements inside)
			//			argsXML.collection = true;
			//			
			// Setup the era meta-data
			argsXML.meta.@action = "replace";
			argsXML.meta["ERA-case"]["RM_code"] = this.rmCode;
			
			if(this.title != "") {
				argsXML.meta["ERA-case"]["title"] = this.title;
			}
			
			// setup the researchers
			for each(var researcher:Model_ERAUser in researcherArray) {
				argsXML.meta["ERA-case"].appendChild(XML("<researcher_username><username>" + researcher.username + "</username><first_name>"+researcher.firstName+"</first_name><last_name>"+researcher.lastName+"</last_name></researcher_username>"));
			}
			
			if(this.qutSchool != "") {
				argsXML.meta["ERA-case"]["qut_school"] = this.qutSchool;
			}
			
			// setup for codes/percentages
			for each(var forElementArray:Array in forArray) {
				argsXML.meta["ERA-case"].appendChild(XML("<for><for_code>" + forElementArray["for_code"] + "</for_code><percentage>" + forElementArray["percentage"] + "</percentage></for>"));
			}
			
			// setup categories
			for each(var category:String in categoryArray) {
				argsXML.meta["ERA-case"].appendChild(XML("<category>" + category + "</category>"));
			}
			
			// setup production manager usernames
			for each(var productionManager:Model_ERAUser in productionManagerArray) {
				argsXML.meta["ERA-case"].appendChild(XML("<production_manager_username><username>" + productionManager.username + "</username><first_name>"+productionManager.firstName+"</first_name><last_name>"+productionManager.lastName+"</last_name></production_manager_username>"));
			}
			
			// setup production team usernames
			for each(var productionTeam:Model_ERAUser in productionTeamArray) {
				argsXML.meta["ERA-case"].appendChild(XML("<production_team_username><username>" + productionTeam.username + "</username><first_name>"+productionTeam.firstName+"</first_name><last_name>"+productionTeam.lastName+"</last_name></production_team_username>"));
			}

			connection.sendRequest(baseXML, eraCaseUpdated);			
		}
		
		private function eraCaseUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("updating era case", e)) == null) {
				callback(false, null);
				return;
			}
				
			// Get out the ERA object
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = caseID;
			
			connection.sendRequest(baseXML, eraCaseRetrieved);
		}
		
		private function eraCaseRetrieved(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting updated era case", e)) == null) {
				callback(false, null);
				return
			}
			
			var eraCase:Model_ERACase = new Model_ERACase();
			eraCase.setData(data.reply.result.asset[0]);
			
			callback(true, eraCase);
		}
	}
}