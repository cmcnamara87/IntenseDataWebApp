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
	
	public class Transaction_CreateERACase
	{
		private var eraID:Number;
		private var year:String;
		private var rmCode:String;
		private var title:String;
		private var fileCount:Number;
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
		
		public function Transaction_CreateERACase(eraID:Number,
												  year:String,
												  rmCode:String, 
												  title:String,
												  fileCount:Number,
												  researcherArray:Array,
												  qutSchool:String, 
												  forArray:Array,
												  categoryArray:Array,
												  productionManagerArray:Array,
												  productionTeamArray:Array,
												  connection:Connection, 
												  callback:Function)
		{
			this.eraID = eraID;	
			this.year = year;
			this.rmCode = rmCode;
			this.title = title;
			this.fileCount = fileCount;
			this.researcherArray = researcherArray;
			this.qutSchool = qutSchool;
			this.forArray = forArray;
			this.categoryArray = categoryArray;
			this.productionManagerArray = productionManagerArray;
			this.productionTeamArray = productionTeamArray;
			this.connection = connection;
			this.callback = callback;
			
			createERACase();
		}
		
		private function createERACase():void {
			var baseXML:XML = connection.packageRequest("asset.create", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// put it in the namespace for this era
			argsXML.namespace = "ERA/" + this.year;
			
			argsXML.type = "ERA/case";
			
			// Setup the ACLS
			// People with access to hte Case are
			// super admin
			// all monitors
			// all the sys admins
			// all viewers
//			argsXML.appendChild(XML('<acl><actor type="role">' + Model_ERAUser.SUPER_ADMIN + '</actor><access>read-write</access></acl>'));
			argsXML.appendChild(XML('<acl><actor type="role">' + Model_ERAUser.SYS_ADMIN + '</actor><access>read-write</access></acl>'));
			argsXML.appendChild(XML('<acl><actor type="role">' + Model_ERAUser.MONITOR + "_" + year + '</actor><access>read-write</access></acl>'));
			argsXML.appendChild(XML('<acl><actor type="role">' + Model_ERAUser.VIEWER + "_" + year + '</actor><access>read-write</access></acl>'));
			argsXML.appendChild(XML('<acl><actor type="role">' + Model_ERAUser.LIBRARY_ADMIN + "_" + year + '</actor><access>read-write</access></acl>'));
//			
			// only the researchers specified
			for each(var researcher:Model_ERAUser in researcherArray) {
				argsXML.appendChild(XML('<acl><actor type="user">system:' + researcher.username + '</actor><access>read-write</access></acl>'));
			}
			
			// only the production managers specified
			for each(var productionManager:Model_ERAUser in productionManagerArray) {
				argsXML.appendChild(XML('<acl><actor type="user">system:' + productionManager.username + '</actor><access>read-write</access></acl>'));
			}
			
			// only the production team specificed
			for each(var productionTeam:Model_ERAUser in productionTeamArray) {
				argsXML.appendChild(XML('<acl><actor type="user">system:' + productionTeam.username + '</actor><access>read-write</access></acl>'));
			}
			
//			
			// Setup the era meta-data
			argsXML.meta["ERA-case"]["RM_code"] = this.rmCode;
			if(this.title != "") {
				argsXML.meta["ERA-case"]["title"] = this.title;
			}
			
			argsXML.meta["ERA-case"]["file_count"] = this.fileCount;

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
			
			// Setup the relationship
			argsXML.related = "";
			argsXML.related.appendChild(XML('<to relationship="era">' + eraID + '</to>'));
			
			connection.sendRequest(baseXML, eraCaseCreated);			
		}
		
		private function eraCaseCreated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("creating era case", e)) == null) {
				callback(false, null);
				return;
			}
			
			newERACaseID = data.reply.result.id;
			
			// Create all the rooms
			roomBeingMadeIndex = 0;
			AppModel.getInstance().createRoomInCase(newERACaseID, Model_ERARoom.ROOM_TYPE_ARRAY[roomBeingMadeIndex], roomCreated);
		}
		
		private function roomCreated(status:Boolean):void {
			if(!status) {
				callback(false, null);
				return
			}
			// now create the next room
			roomBeingMadeIndex++;
			if(roomBeingMadeIndex == Model_ERARoom.ROOM_TYPE_ARRAY.length) {
				// We have made all the rooms
				roomCreationCompleted();
			} else {
				AppModel.getInstance().createRoomInCase(newERACaseID, Model_ERARoom.ROOM_TYPE_ARRAY[roomBeingMadeIndex], roomCreated);
			}
		}
		
		private function roomCreationCompleted():void {
			// Get out the ERA object
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = newERACaseID;
			
			connection.sendRequest(baseXML, eraCaseRetrieved);
		}
		
		private function eraCaseRetrieved(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting era case", e)) == null) {
				callback(false, null);
				return
			}
			
			var eraCase:Model_ERACase = new Model_ERACase();
			eraCase.setData(data.reply.result.asset[0]);
			
			callback(true, eraCase);
		}
	}
}