package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import View.ERA.components.ERARole;

	public class Transaction_CreateAllResearchers
	{
		private var userList:String = "Armstrong, Keith,k.armstrong@qut.edu.au*Arthurs, Andy,a.arthurs@qut.edu.au*Brown, Andrew,a.brown@qut.edu.au*Burgess, Jean,je.burgess@qut.edu.au*Collis, Christy ,c.collis@qut.edu.au*Comans, Christine,c.comans@qut.edu.au*Denaro, Chris ,c.denaro@qut.edu.au*Duffield, Lee,l.duffield@qut.edu.au*Foth, Marcus,m.foth@qut.edu.au*Gattenhof, Sandra,s.gattenhof@qut.edu.au*Hearn, Greg,g.hearn@qut.edu.au*Hewitt, Donna,donna.hewitt@qut.edu.au*Jenkins, Greg,g2.jenkins@qut.edu.au*Klaebe, Helen ,h.klaebe@qut.edu.au*Knowles, Julian,julian.knowles@qut.edu.au*Makeham, Paul,p.makeham@qut.edu.au*McNamara, Andrew,a.mcnamara@qut.edu.au*Megarrity, David,d.megarrity@qut.edu.au*Neilsen, Philip,p.neilsen@qut.edu.au*Polson, Debra,d.polson@qut.edu.au*Portmann, Geoff,g.portmann@qut.edu.au*Radvan, Mark,m.radvan@qut.edu.au*Robb, Charles,c.robb@qut.edu.au*Romano, Angela,a.romano@qut.edu.au*Sade, Gavin,g.sade@qut.edu.au*Schroeter, Ronald,r.schroeter@qut.edu.au*Silver, John ,jon.silver@qut.edu.au*Sorensen, Andrew,a.sorensen@qut.edu.au*Spurgeon, Christina,c.spurgeon@qut.edu.au*Stock, Cheryl,c.stock@qut.edu.au*Street, Susan,s.street@qut.edu.au*Thomas, Lubi,lubi.thomas@qut.edu.au*Turner, Jane ,j.turner@qut.edu.au*Willsteed, John,j.willsteed@qut.edu.au";
				
		private var year:String;
		
		public function Transaction_CreateAllResearchers(year:String, userList:String="")
		{
			this.year = year;
			
			if(userList != "") {
				this.userList = userList;
			}
			
			var usersArray:Array = userList.split("*");
			for each(var userData:String in usersArray) {
				var userDataArray = userData.split(",");
				var lastName:String = userDataArray[0];
				var firstName:String = userDataArray[1];
				var email:String = userDataArray[2];
				
				trace("new User is", email, firstName, lastName);
				
				AppModel.getInstance().createERAUser(email, firstName, lastName, userCreated);
			}
		}
		
		private function userCreated(status:Boolean, eraUser:Model_ERAUser=null):void {
			if(!status) {
				trace("failed to create the user");
				return;
				
			}
			
			trace("User created for", eraUser.username);
			AppModel.getInstance().addRoleToERAUser(eraUser, Model_ERAUser.RESEARCHER, year, null, userAddedToRole);
				
				// callback(true, userData, roleComponent);
		}
		
		private function userAddedToRole(status:Boolean, eraUser:Model_ERAUser=null, roleComponent:ERARole=null) {
			if(!status) {
				trace("failed to add user to role");	
			}
			

			trace("Role added for", eraUser.username);
			
		}
	}
}