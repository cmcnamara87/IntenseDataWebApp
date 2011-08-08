package Model.Transactions
{
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	/**
	 * Creates a User in the Mediaflux Database.
	 * 
	 * Creates a 'user' actor, and assigns the 'user' role to it. 
	 * @author cmcnamara87
	 * 
	 */	
	public class Transaction_CreateUser
	{
		private var username:String;
		private var password:String;
		private var email:String;
		private var domain:String;
		private var r_user:Object;
		private var callback:Function;
		private var connection:Connection;
		/**
		 * Saves all the info needed to create a user,
		 * and creates the user.
		 *  
		 * @param username	The user name for the user
		 * @param password	The password for the user
		 * @param email		The email for the user
		 * @param domain	The domain the user will be in (currently using system, TODO)
		 * @param details	An object that contains all the details for a user, matching the r_user doc type
		 * @param callback	The function to call when the transaction is complete
		 * 
		 */		
		public function Transaction_CreateUser(username:String,
											   password:String,
											   email:String,
											   domain:String,
											   r_user:Object,
											   connection:Connection,
											   callback:Function)
		{
			trace("- Create User Transaction");
			this.username = username;
			this.password = password;
			this.email = email;
			this.domain = domain;
			this.r_user = r_user;
			this.connection = connection;
			this.callback = callback;
			
			createUser();
			
		}
		
		/**
		 * Creates the user actor in the database, then calls @see grantUserRole 
		 * @return 
		 * 
		 */		
		private function createUser():void {

			// Create the transaction
			var args:Object = new Object();
			args.user = username;
			args.password = password;
			args.domain = domain;
			args.email = email;
			
			trace("connection: ", connection);
			trace("args:", args);
			// Create a request
			var baseXML:XML = connection.packageRequest('user.create', args, true);
			
			trace("Transaction_CreateUser:createUser - Telephone is", r_user.meta_tel_home);
			// Assemble the Meta Data
			// For some reason, the meta data has the username, password and email in it, even though
			// the user already has that data, but whatever.
			baseXML.service.args["meta"]["r_user"]["username"] = username;
			baseXML.service.args["meta"]["r_user"]["password"] = password;
			baseXML.service.args["meta"]["r_user"]["email"] = r_user.email;
			// These are all optional, so we check that they arent blank
			
			if(r_user.meta_firstname == "") 	r_user.meta_firstname = " ";
			if(r_user.meta_lastname == "") 		r_user.meta_lastname = " ";
			if(r_user.meta_email == "") 			r_user.meta_email = " ";
			if(r_user.meta_initial == "") 		r_user.meta_initial = " ";
			if(r_user.meta_organisation == "") 	r_user.meta_organisation = " ";
			if(r_user.meta_url == "") 			r_user.meta_url = " ";
			if(r_user.meta_tel_business == "") 	r_user.meta_tel_business = " ";
			if(r_user.meta_tel_home == "") 		r_user.meta_tel_home = " ";
			if(r_user.meta_tel_mobile == "") 	r_user.meta_tel_mobile = " ";
			if(r_user.meta_Address_1 == "") 	r_user.meta_Address_1 = " ";
			if(r_user.meta_Address_2 == "") 	r_user.meta_Address_2 = " ";
			if(r_user.meta_Address_3 == "") 	r_user.meta_Address_3 = " ";
			
			baseXML.service.args["meta"]["r_user"]["firstname"] = r_user.meta_firstname;
			baseXML.service.args["meta"]["r_user"]["lastname"] = r_user.meta_lastname;
			baseXML.service.args["meta"]["r_user"]["initial"] = r_user.meta_initial;
			baseXML.service.args["meta"]["r_user"]["organisation"] = r_user.meta_organisation;
			baseXML.service.args["meta"]["r_user"]["url"] = r_user.meta_url;
			baseXML.service.args["meta"]["r_user"]["tel_business"] = r_user.meta_tel_business;
			baseXML.service.args["meta"]["r_user"]["tel_home"] = r_user.meta_tel_home;
			baseXML.service.args["meta"]["r_user"]["tel_mobile"] = r_user.meta_tel_mobile;
			baseXML.service.args["meta"]["r_user"]["Address_1"] = r_user.meta_Address_1;
			baseXML.service.args["meta"]["r_user"]["Address_2"] = r_user.meta_Address_2;
			baseXML.service.args["meta"]["r_user"]["Address_3"] = r_user.meta_Address_3;
			
			if(connection.sendRequest(baseXML, grantUserRole)) {
				//All good
				trace("- User Saved");
			} else {
				trace("Could not save");
				Alert.show("Could not save");
			}
		}
		
		private function grantUserRole(e:Event):void {
			// actor.grant :type user :name system:johnsmith :role user -type role
			trace("- Giving the user the role USER");
			// Create the transaction
			var args:Object = new Object();
			args.type = 'user';
			args.name = domain + ":" + username;
			args.role = 'user';
			
			// Create a request
			var baseXML:XML = connection.packageRequest('actor.grant', args, true);
			
			baseXML.service.args.role.@type = 'role';
			
			if(connection.sendRequest(baseXML, grantIDUserRole)) {
				//All good
				trace("- Saved");
			} else {
				trace("Could not save");
				Alert.show("Could not save");
			}
		}
		
		private function grantIDUserRole(e:Event):void {
			// actor.grant :type user :name system:johnsmith :role iduser -type role
			trace("- Giving the user the role IDUSER");
			// Create the transaction
			var args:Object = new Object();
			args.type = 'user';
			args.name = domain + ":" + username;
			args.role = 'iduser';
			
			// Create a request
			var baseXML:XML = connection.packageRequest('actor.grant', args, true);
			
			baseXML.service.args.role.@type = 'role';
			
			if(connection.sendRequest(baseXML, finishedCreating)) {
				//All good
				trace("- Saved");
			} else {
				trace("Could not save");
				Alert.show("Could not save");
			}
		}
		
		private function finishedCreating(e:Event):void {
			trace("- User created:", e);
			callback(username);
		}
	}
}