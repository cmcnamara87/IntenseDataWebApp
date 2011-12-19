package Model
{
	import Controller.AppController;
	import Controller.Utilities.Auth;
	
	import flash.sampler.Sample;

	public class Model_ERANotification extends Model_Base
	{
		// comment made
		public static const FILE_COMMENT:String = "file_comment";
		// {user} wrote {comment text/id} on {file name/id} {room name/id} -> have commen text/id, have file id, have room id, need filename and room name
		
		public static const ROOM_COMMENT:String = "room_comment";
		// {user} wrote {comment text/id} in {room name/id} -> have comment text/id, and room id, need room name
		
		// annotation made
		public static const ANNOTATION:String = "annotation";
		// {user} wrote {comment text } on {file name} in {room name/id} -> have commen text/id, file id, and room id, need file name nad room name
		
		// file moved to screening lab
		public static const FILE_MOVED_TO_SCREENING_LAB:String = "file_moved_to_screening_lab";
		// {user} moved {file name/id} to {room name/id} -> have file id, room id, room name (nothing needed)
		
		public static const FILE_MOVED_TO_EXHIBITION:String = "file_moved_to_exhibition";
		// {user} moved {file name/id} to {room name/id} -> have file id, room id, room name (nothing needed)
		
		public static const FILE_MOVED_TO_FORENSIC_LAB:String = "file_moved_to_forensic_lab";
		
		// file uploaded
		public static const FILE_UPLOADED:String =  "file_uploaded";
		// {user} uploaded {file name/id} to {room name/id} -> have file id, room id, room name (nothing needed)
		
		// ready for collection
		public static const EVIDENCE_READY_FOR_COLLECTION:String = "evidence_ready_for_collection";
		// {user} marked {evidence name/id} as ready for collection in {room name/id} -> have evidence id, need evidence name, room id and room name
		
		public static const EVIDENCE_COLLECTED:String = "evidence_collected";
		// {user} marked {evidence name/id} evidence as collected in {room name/id} -> have evidence id, need evidence name, room id nad room name
		
		public static const FILE_APPROVED_BY_RESEARCHER:String = "file_approve_by_researcher";
		public static const FILE_NOT_APPROVED_BY_RESEARCHER:String = "file_not_approve_by_researcher";
		
		public static const FILE_APPROVED_BY_MONITOR:String = "file_approved_by_monitor";
		public static const FILE_NOT_APPROVED_BY_MONITOR:String = "file_not_approved_by_monitor";
				
		public static const SHOW_READ:String = "show_read";
		public static const SHOW_UNREAD:String = "show_unread";
		public static const SHOW_ALL:String = "show_all";
		
		public var type:String;
		public var username:String;
		public var firstName:String;
		public var lastName:String;
		public var fullName:String;
		public var creationDateStamp:String;
		public var read:Boolean = false;
		
		public var eraCase:Model_ERACase = null;
		public var room:Model_ERARoom = null;
		public var file:Model_ERAFile = null;
		public var logItem:Model_ERALogItem = null;
		public var comment_room:Model_ERAConversation = null;
		public var comment_file:Model_Commentary = null;
		public var annotation_file:Model_Commentary = null;
		
		public function Model_ERANotification()
		{
			super();
		}

		// Sets the specific data for the collection type
		override protected function setSpecificData():void {
			// grab out the case info
			var eraNotification:XML = rawData.meta["ERA-notification"][0];
			
			// set the type of the item (e.g. video, image etc)
			this.type = eraNotification["type"];
			
			this.username = eraNotification["username"];
			this.firstName = eraNotification["first_name"];
			this.lastName = eraNotification["last_name"];
			this.fullName = firstName + " " + lastName;
			
			// Setup the creation time
			var currDate:Date = new Date(rawData.ctime.@millisec);
			this.creationDateStamp = (currDate.getHours() + ":" + currDate.getMinutes() + " - " + currDate.getDate() + "/" + (currDate.getMonth()+ 1) + "/" + currDate.getFullYear());
			
			for each(var readUser:XML in rawData.meta["ERA-notification"]["read_by_users"]) {
				if(readUser.username == Auth.getInstance().getUsername() && readUser.read_status == "true") {
					// its been read by the current user, so make it as read
					this.read = true;
				}
			}
			
			this.eraCase = new Model_ERACase();
			if(rawData.related.(@type=="notification_case").asset.length() > 0) {
				eraCase.setData(rawData.related.(@type=="notification_case").asset[0]);
			}
			
			if(rawData.related.(@type=="notification_room").asset.length()) {
				// a room is given, lets store it
				room = new Model_ERARoom();
				room.setData(rawData.related.(@type=="notification_room").asset[0]);
			}
			if(rawData.related.(@type=="notification_comment").asset.length()) {
				if(this.type == FILE_COMMENT || this.type == ANNOTATION) {
					comment_file = new Model_Commentary();
					comment_file.setData(rawData.related.(@type=="notification_comment").asset[0]);
				} else if (this.type == ROOM_COMMENT) {
					comment_room = new Model_ERAConversation();
					comment_room.setData(rawData.related.(@type=="notification_comment").asset[0]);
				}
			}
			if(rawData.related.(@type=="notification_file").asset.length()) {
				if(this.type == EVIDENCE_COLLECTED || this.type == EVIDENCE_READY_FOR_COLLECTION) {
					logItem = new Model_ERALogItem();
					logItem.setData(rawData.related.(@type=="notification_file").asset[0]);
				} else {//if(this.type == FILE_APPROVED_BY_RESEARCHER || this.type == FILE_NOT_APPROVED_BY_RESEARCHER || this.type == FILE_COMMENT || this.type == ANNOTATION || this.type == FILE_MOVED_TO_SCREENING_LAB || this.type == FILE_MOVED_TO_FORENSIC_LAB || this.type == FILE_MOVED_TO_EXHIBITION || this.type == FILE_UPLOADED) {
					file = new Model_ERAFile();
					file.setData(rawData.related.(@type=="notification_file").asset[0]);
				}
			}
		}
		
		public static function getEmailMessage(notificationData:Model_ERANotification, isStaff:Boolean, isExternal:Boolean):Object {
			var messageObject = new Object();
			
			if(isStaff) {
				messageObject.subject = "New nQuisitor Notification  (RM " + notificationData.eraCase.rmCode + "): ";
				messageObject.body = "Hi, You have a new nQuisitor Notification:\n\n";
			} else if(isExternal) {
				messageObject.subject = "nQusitor Notification (RM " + notificationData.eraCase.rmCode + "): ";
				messageObject.body = "";
			}
			
			switch(notificationData.type) {
				case Model_ERANotification.FILE_APPROVED_BY_RESEARCHER:
					messageObject.subject += "File Approved for ERA Submission by Researcher";
					if(isStaff) {
						messageObject.body += "Researcher " + notificationData.fullName + " approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for ERA submission.";
					} else if (isExternal) {
						messageObject.body += "This is an email to confirm that Researcher " + notificationData.fullName + " approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for case '" + notificationData.eraCase.title + "' for ERA submission.";
					}
					break;
				case Model_ERANotification.FILE_NOT_APPROVED_BY_RESEARCHER:
					messageObject.subject += "File Not Approved for ERA Submission by Researcher";
					if(isStaff) {
						messageObject.body += "Researcher " + notificationData.fullName + " has not approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for ERA submission.";
					} else if (isExternal) {
						messageObject.body += "This is an email to confirm that Researcher " + notificationData.fullName + " has not approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for case '" + notificationData.eraCase.title + "' for ERA submission.";
					}
					break;
				case Model_ERANotification.FILE_APPROVED_BY_MONITOR:
					messageObject.subject += "File Approved for ERA Submission by Monitor";
					if(isStaff) {
						messageObject.body += "Monitor " + notificationData.fullName + " approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for ERA submission.";
					} else if (isExternal) {
						messageObject.body += "This is an email to confirm that Monitor " + notificationData.fullName + " approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for case '" + notificationData.eraCase.title + "' for ERA submission.";
					}
					break;
				case Model_ERANotification.FILE_NOT_APPROVED_BY_MONITOR:
					messageObject.subject += "File Not Approved for ERA Submission by Monitor";
					if(isStaff) {
						messageObject.body += "Monitor " + notificationData.fullName + " has not approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for ERA submission.";
					} else if (isExternal) {
						messageObject.body += "This is an email to confirm that Monitor " + notificationData.fullName + " has not approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for case '" + notificationData.eraCase.title + "' for ERA submission.";
					}
					break;
				case Model_ERANotification.FILE_UPLOADED:					
				
					if(isStaff) {
						messageObject.subject += "New File Uploaded";
						messageObject.body += notificationData.fullName + " uploaded '" + notificationData.file.title + "' to " + notificationData.room.roomTitle + " for case '" + notificationData.eraCase.title + "'.";
					} else if(isExternal) {
						messageObject.subject += "Evidence now uploaded to nQuisitor Evidence Box";
						messageObject.body += "This is an email to confirm that a piece of your research evidence \"" + notificationData.file.title + "\" for case '" + notificationData.eraCase.title + "' has now been digitized and is available in the online nQusitior Evidence Box ready for your comments.";
					}

					break;
				case Model_ERANotification.ROOM_COMMENT:
					if(isStaff) {
						messageObject.subject += "New Comment";
						messageObject.body += notificationData.fullName + " wrote \"" + notificationData.comment_room.text + "\" on " + notificationData.room.roomTitle + " for case '" + notificationData.eraCase.title + "'";
					} else if (isExternal) {
						messageObject.subject += "Your Researcher has Attacted Commentary";
						messageObject.body += "An nQuisitor collaborator (" + notificationData.fullName + ") commented \"" + notificationData.comment_room.text + "\" on " + notificationData.room.roomTitle + " for case '" + notificationData.eraCase.title + "'"; 
					}
					break;
				case Model_ERANotification.FILE_MOVED_TO_SCREENING_LAB:
				case Model_ERANotification.FILE_MOVED_TO_EXHIBITION:
				case Model_ERANotification.FILE_MOVED_TO_FORENSIC_LAB:
					if(isStaff) {
						messageObject.subject += "File Moved";
						messageObject.body += "" + notificationData.fullName + " moved " + notificationData.file.title + " to " + notificationData.room.roomTitle + " for case '" + notificationData.eraCase.title + "'";
					} else if (isExternal) {
						messageObject.subject += "Proposed ERA Submission Piece Ready for Review in " + notificationData.room.roomTitle;
						messageObject.body += "This is an email to confirm that an nQuisitor Collaborator has placed a proposed ERA submission piece \"" + notificationData.file.title + "\" in the " + notificationData.room.roomTitle +  " for case '" + notificationData.eraCase.title + "'. Please log in, review (by commenting) and approve or disapprove this file for ERA submission";
					}
					break;
				case Model_ERANotification.FILE_COMMENT:
					if(isStaff) {
						messageObject.subject += "New Comment";
						messageObject.body += "" + notificationData.fullName + " commented \"" + notificationData.comment_file.annotation_text + "\" on " + notificationData.file.title + " in " + notificationData.room.roomTitle + ".";
					} else if (isExternal) {
						messageObject.subject += "Your Researcher has Attacted Commentary";
						messageObject.body += "An nQuisitor collaborator (" + notificationData.fullName + ") commented \"" + notificationData.comment_file.annotation_text + "\" on " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for case '" + notificationData.eraCase.title + "'";
					}
					break
				case Model_ERANotification.ANNOTATION:
					if(isStaff) {
						messageObject.subject += "New Annotation";
						messageObject.body += notificationData.fullName + " commented \"" + notificationData.comment_file.annotation_text + "\" on " + notificationData.file.title + " in " + notificationData.room.roomTitle + ".";
					} else if (isExternal) {
						messageObject.subject += "Your Researcher has Attacted Commentary";
						messageObject.body += "An nQuisitor collaborator (" + notificationData.fullName + ") commented \"" + notificationData.comment_file.annotation_text + "\" on " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for case '" + notificationData.eraCase.title + "'";
					}
					break;
				case Model_ERANotification.EVIDENCE_COLLECTED:
					if(isStaff) {
						messageObject.subject += "Evidence Collected";
						messageObject.body = "" + notificationData.fullName + " marked " + notificationData.logItem.title + " as collected by a researcher in " + notificationData.room.roomTitle + ".";	
					} else if (isExternal) {
						messageObject.subject += "Physical Evidence Has Been Collected";
						messageObject.body = "This is an email to confirm that evidence item \"" + notificationData.logItem.title + " has been signed up and collected by you from case " + notificationData.eraCase.title + ". If youy have any queries please return this email highlighting your concerns.";
					}
					break;
				case Model_ERANotification.EVIDENCE_READY_FOR_COLLECTION:
					if(isStaff) {
						messageObject.subject += "Evidence Ready for Collection";
						messageObject.body += "" + notificationData.fullName + " marked " + notificationData.logItem.title + " as ready for collection in " + notificationData.room.roomTitle + ".";
					} else if (isExternal) {
						messageObject.subject += "Physical Research Now Ready for Collection";
						messageObject.body += "This email is to indicate that a physical element of your research \"" + notificationData.logItem.title + "\" has been digitized and is ready for collection in the ERA production room.";
					}
					break;
				default:
					break;
			}
			
			messageObject.body += "\n\nVisit nQuisitor at http://cifera.qut.edu.au/";
			
			if(isExternal) {
				// Add the external disclaimer
			
				// attach footer stuff
				var signOff:String = "\n\nRegards\n\n";
				signOff += "Peter Hempenstall\n\n";
				signOff += "Senior Research Assistant\n";
				signOff += "CIF - ERA Coordinator\n";
				signOff += "Non-Traditional Research Outputs\n";
				signOff += "Queensland University of Technology\n";
				signOff += "p.hempenstall@qut.edu.au\n\n\n";
				
				var disclaimer:String = "QUT disclaims all warranties with regard to this information, including all implied warranties of merchantability " +
					"and fitness, in no event shall QUT be liable or any special, indirect or consequential damages or any damages " +
					"whatsoever resulting from loss of use, data or profits, whether in an action of contract, negligence or other tortious " +
					"action, arising out of or in connection with the use or performance of this information.\n\n";
				disclaimer += "This information may include technical inaccuracies or typographical errors.\n\n";
				disclaimer += "QUT is not responsible to you or anyone else for any loss, direct or incidental, suffered in connection with the use of" +
					"this website or any of the content.\n\n";
				disclaimer += "QUT makes no warranties or representations about this website or any of the content. We exclude, to the maximum " +
					"extent permitted by law, any liability which may arise as a result of the use of this website, its content or the" +
					"information on it.";
				disclaimer += "Where liability cannot be excluded, any liability incurred by us in relation to the use of this website or the content is " +
					"limited as provided under the Trade Practices Act 1974 (s68A). We will never be liable for any indirect, incidental, " +
					"special or consequential loss arising out of the use of this website, including loss of business profits. " +
					"QUT may make improvements and/or changes in the information at any time."
					
				messageObject.body += signOff + disclaimer;

			}		
			
			return messageObject;
		}
		
		public static function getWhoToNotify(notificationType:String, eraCase:Model_ERACase, eraRoom:Model_ERARoom):Object {
			var userObject:Object = new Object();
			userObject.roles = new Array();
			userObject.users = new Array();
			
			// The sys admin should get all notifications
			(userObject.roles as Array).push(Model_ERAUser.SYS_ADMIN + "_" + AppController.currentEraProject.year);
			
			// Notify the production manager whenever someone else does something (or, they upload a file)
			for each(var productionManager:Model_ERAUser in eraCase.productionManagerArray) {
				if(productionManager.username == Auth.getInstance().getUsername() && notificationType !=  Model_ERANotification.FILE_UPLOADED) continue;
				(userObject.users as Array).push(productionManager.username);	
			}
			
			// Notifiy the production team member whenever someone else does something (or, they upload a file)
			for each(var productionTeamMember:Model_ERAUser in eraCase.productionTeamArray) {
				if(productionTeamMember.username == Auth.getInstance().getUsername() && notificationType !=  Model_ERANotification.FILE_UPLOADED) continue;
				(userObject.users as Array).push(productionManager.username);	
			}
			
			// Notify researcher
			// FILE_COMMENT/ANNOTATION/ROOM_COMMENT if in evidence or review lab
			// FILE_MOVED_TO_SCREENING_LAB, EVIDENCE_READY_FOR_COLLECTION, EVIDENCE_COLLECTED, FILE_APPROVED_BY_RESEARCHER, FILE_NOT_APPROVED_BY_RESEARCHER
			if(	notificationType == Model_ERANotification.FILE_MOVED_TO_SCREENING_LAB ||
				notificationType == Model_ERANotification.EVIDENCE_READY_FOR_COLLECTION ||
				notificationType == Model_ERANotification.EVIDENCE_COLLECTED ||
				notificationType == Model_ERANotification.FILE_APPROVED_BY_RESEARCHER ||
				notificationType == Model_ERANotification.FILE_NOT_APPROVED_BY_RESEARCHER ||
				notificationType == Model_ERANotification.FILE_UPLOADED ||
				((notificationType == Model_ERANotification.FILE_COMMENT || notificationType == Model_ERANotification.ANNOTATION || notificationType == Model_ERANotification.ROOM_COMMENT)
					&& (eraRoom.roomType == Model_ERARoom.EVIDENCE_ROOM ||  eraRoom.roomType == Model_ERARoom.SCREENING_ROOM))
			) {
				for each(var researcher:Model_ERAUser in eraCase.researchersArray) {
					if(productionTeamMember.username == Auth.getInstance().getUsername() && 
						(	notificationType !=  Model_ERANotification.FILE_APPROVED_BY_RESEARCHER || 
							notificationType !=  Model_ERANotification.FILE_NOT_APPROVED_BY_RESEARCHER || 
							notificationType !=  Model_ERANotification.EVIDENCE_COLLECTED
						)
					) continue;
					(userObject.users as Array).push(researcher.username);
				}
			}
			
			// Monitor
			if(notificationType == Model_ERANotification.FILE_MOVED_TO_SCREENING_LAB ||
				notificationType == Model_ERANotification.FILE_APPROVED_BY_MONITOR || 
				notificationType == Model_ERANotification.FILE_NOT_APPROVED_BY_MONITOR
			) {
				// Notify the monitor when fiels are ready to be screened or exhibited
				(userObject.roles as Array).push(Model_ERAUser.MONITOR + "_" + AppController.currentEraProject.year);
			}
			
			
			return userObject;
		}
	}
}