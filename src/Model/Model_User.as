package Model {
	
	import Controller.Dispatcher;
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	import flash.utils.describeType;
	
	public class Model_User extends Model_Base {
		
		public var type:String = "";
		
		/* BASIC */
		public var base_type:String;
		public var base_modifier_id:Number;
		
		/* META */
		public var meta_user_id:Number;
		public var meta_password:String; // Should not even exist!!!!
		public var meta_firstname:String;
		public var meta_lastname:String;
		public var meta_email:String;
		public var meta_initial:String;
		public var meta_organisation:String;
		public var meta_url:String;
		public var meta_tel_business:String;
		public var meta_tel_home:String;
		public var meta_tel_mobile:String;
		public var meta_Address_1:String;
		public var meta_Address_2:String;
		public var meta_Address_3:String;
		
		
		public function Model_User() {
			super();
		}
		
		// Sets the specific data for the media type
		override protected function setSpecificData():void {
			base_type = rawData.type;
			base_modifier_id = rawData.modifier.@id;
			
			if(rawData.meta.r_user.meta_firstname == " ") 	rawData.meta.r_user.meta_firstname = "";
			if(rawData.meta.r_user.meta_lastname == " ") 	rawData.meta.r_user.meta_lastname = "";
			if(rawData.meta.r_user.meta_email == " ") 		rawData.meta.r_user.meta_email = "";
			if(rawData.meta.r_user.meta_initial == " ") 		rawData.meta.r_user.meta_initial = "";
			if(rawData.meta.r_user.meta_organisation == " ") rawData.meta.r_user.meta_organisation = "";
			if(rawData.meta.r_user.meta_url == " ") 			rawData.meta.r_user.meta_url = "";
			if(rawData.meta.r_user.meta_tel_business == " ") rawData.meta.r_user.meta_tel_business = "";
			if(rawData.meta.r_user.meta_tel_home == " ") 	rawData.meta.r_user.meta_tel_home = "";
			if(rawData.meta.r_user.meta_tel_mobile == " ") 	rawData.meta.r_user.meta_tel_mobile = "";
			if(rawData.meta.r_user.meta_Address_1 == " ") 	rawData.meta.r_user.meta_Address_1 = "";
			if(rawData.meta.r_user.meta_Address_2 == " ") 	rawData.meta.r_user.meta_Address_2 = "";
			if(rawData.meta.r_user.meta_Address_3 == " ") 	rawData.meta.r_user.meta_Address_3 = "";
			
			meta_user_id = rawData.meta.r_user.@id;
			meta_username = rawData.meta.r_user.username;
			meta_password = rawData.meta.r_user.password;
			meta_firstname = rawData.meta.r_user.firstname;
			meta_lastname = rawData.meta.r_user.lastname;
			meta_email = rawData.meta.r_user.email;
			meta_initial = rawData.meta.r_user.initial;
			meta_organisation = rawData.meta.r_user.organisation;
			meta_url = rawData.meta.r_user.url;
			meta_tel_business = rawData.meta.r_user.tel_business + ""; // adding "" to keep it backwards compatible (since it used to be a number)
			meta_tel_home = rawData.meta.r_user.tel_home + "";
			meta_tel_mobile = rawData.meta.r_user.tel_mobile + "";
			meta_Address_1 = rawData.meta.r_user.Address_1;
			meta_Address_2 = rawData.meta.r_user.Address_2;
			meta_Address_3 = rawData.meta.r_user.Address_3;
		}
	}
	
}