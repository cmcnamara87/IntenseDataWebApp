package Controller.ERA.Admin
{
	import Controller.AppController;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAFile;
	import Model.Model_ERAUser;
	
	import View.ERA.ReportsView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import org.alivepdf.colors.RGBColor;
	import org.alivepdf.fonts.CodePage;
	import org.alivepdf.fonts.CoreFont;
	import org.alivepdf.fonts.EmbeddedFont;
	import org.alivepdf.fonts.FontFamily;
	import org.alivepdf.fonts.IFont;
	import org.alivepdf.layout.Orientation;
	import org.alivepdf.layout.Size;
	import org.alivepdf.layout.Unit;
	import org.alivepdf.pdf.PDF;
	import org.alivepdf.saving.Method;
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	import spark.components.Button;
	
	public class ReportController extends AppController
	{
		[Embed( source="/Assets/Fonts/MyriadWebPro.TTF", mimeType="application/octet-stream" )]
		private var fontStream:Class;
		
		[Embed( source="/Assets/Fonts/myriad.afm", mimeType="application/octet-stream" )]
		private var afmStream:Class;
		
		private var uf:IFont = new CoreFont(FontFamily.ARIAL);
		
		private static var myriadFont:EmbeddedFont;
		
		private var selectedReport:String = "";
		// the data for the last generated report
		private var reportData:ByteArray = null;
		
		private var reportsView:ReportsView;
		
		
		public static const REPORT_RESEARCHERS_IN_SCHOOLS:String = "REPORT_RESEARCHERS_IN_SCHOOLS";
		public static const REPORT_CASES_IN_EXHIBITION:String = "REPORT_CASES_IN_EXHIBITION";
		public static const REPORT_CASES_NOT_COLLECTED:String = "REPORT_CASES_NOT_COLLECTED";
		public static const REPORT_CHECKED_OUT:String = "REPORT_CHECKED_OUT";
		public static const REPORT_RESEARCHERS_NOT_INVOLVED:String = "REPORT_RESEARCHERS_NOT_INVOLVED";
		
		public function ReportController()
		{
			reportsView = new ReportsView();
			view = reportsView;
			super();
		}
		
		override public function init():void {
			// Create our font
			myriadFont = new EmbeddedFont(new fontStream(), new afmStream(), CodePage.CP1254);
			
			setupEventListeners();
		}
		
		private function setupEventListeners():void {
			reportsView.generateButton.addEventListener(MouseEvent.CLICK, generateReport, false, 0, true);
			reportsView.reportDropdown.addEventListener(Event.CHANGE, reportDropdownChanged, false, 0, true);
		}
		private function reportDropdownChanged(e:Event):void {
			selectedReport = "";
			reportData = null;
			reportsView.generateButton.label = "Generate";
		}
		
		private function generateReport(e:MouseEvent):void {
			if(selectedReport != "" && reportData != null) {
				// we have a selected report, and data for it
				// so show it
				var newReport:FileReference = new FileReference();
				newReport.save(reportData, "report.pdf");
				return;
			}
			
			// making a new report
			// find out what the selected report is
			var selectedReport:String = reportsView.reportDropdown.selectedItem.data;
			
			switch(selectedReport) {
				case REPORT_RESEARCHERS_IN_SCHOOLS:
					makeResearcherSchoolReport();
					break;
				case REPORT_CASES_IN_EXHIBITION:
					makeCasesInExhibitionReport();
					break;
				case REPORT_CASES_NOT_COLLECTED:
					makeCasesNotCollectedReport();
					break;
				case REPORT_CHECKED_OUT:
					makeFilesCheckedInOutReport();
					break;
				case REPORT_RESEARCHERS_NOT_INVOLVED:
					makeCasesResearchersNotInvolved();
			}			
		}
			
		
		/* =============================== MAKE CASES EVIDENCE NOT COLLECTED ===================================== */
		private function makeCasesResearchersNotInvolved():void {
			// Change button to say generating
			reportsView.generateButton.label = "Generating";
			layout.notificationBar.showProcess("Generating Report...");
			AppModel.getInstance().getCasesResearchersNoInvolvement(gotCasesResearchersNotInvolved);
		}
		private function gotCasesResearchersNotInvolved(status:Boolean, eraCaseArray:Array=null):void {
			if(!status) {
				reportsView.generateButton.label = "Generate";
				layout.notificationBar.showError("Failed to generate Report");
				return;
			}
			layout.notificationBar.showGood("Finished Generating");
			reportsView.generateButton.label = "View";
			
			var p:PDF = makeReportWithHeader("Cases with No Researcher Involvement");
			
			p.setFont(myriadFont, 10);
			for each(var eraCase:Model_ERACase in eraCaseArray) {
				
				p.writeText(10, "RM Code: " + eraCase.rmCode + "\n");
				p.writeText(10, "Title: " + eraCase.title + "\n");
				p.writeText(10, "Researchers:\n");
				for each(var caseResearcher:Model_ERAUser in eraCase.researchersArray) {
					p.writeText(12, caseResearcher.lastName + ", " + caseResearcher.firstName + "\n");
				}
				p.writeText(12, "\n");
			}
			
			reportData = p.save( Method.LOCAL );
		}
		/* =============================== END OF MAKE CASES EVIDENCE NOT COLLECTED ===================================== */
		
		
		/* =============================== MAKE FILES CHECKED IN OUT REPORT ===================================== */
		private function makeFilesCheckedInOutReport():void {
			// Change button to say generating
			reportsView.generateButton.label = "Generating";
			layout.notificationBar.showProcess("Generating Report...");
			AppModel.getInstance().getCheckedInOutFilesPerCase(gotFilesCheckedInOut);
		}
		private function gotFilesCheckedInOut(status:Boolean, eraCaseFileArray:Array=null):void {
			if(!status) {
				reportsView.generateButton.label = "Generate";
				layout.notificationBar.showError("Failed to generate Report");
				return;
			}
			layout.notificationBar.showGood("Finished Generating");
			reportsView.generateButton.label = "View";
			
			var p:PDF = makeReportWithHeader("File Checkout Status Per Case");

			p.setFont(myriadFont, 10);
			for each(var eraCaseFileObject:Object in eraCaseFileArray) {
				var eraCase:Model_ERACase = eraCaseFileObject.eraCase;
				var fileArray:Array = eraCaseFileObject.files;
				
				
				p.writeText(10, "RM Code: " + eraCase.rmCode + "\n");
				p.writeText(10, "Title: " + eraCase.title + "\n");
				p.writeText(10, "Researchers:\n");
				for each(var caseResearcher:Model_ERAUser in eraCase.researchersArray) {
					p.writeText(12, caseResearcher.lastName + ", " + caseResearcher.firstName + "\n");
				}
				p.writeText(10, "Files:\n");
				for each(var file:Model_ERAFile in fileArray) {
					if(file.checkedOut) {
						p.writeText(12, "\t" + file.title + " - Checked out by:" + file.checkedOutUsername + "\n");
					} else {
						p.writeText(12, "\t" + file.title + "\n");
					}
				}
				p.addPage();
//				p.writeText(12, "\n\n");
			}
			p.writeText(12, "\n\n\n");
			reportData = p.save( Method.LOCAL );
		}
		
		/* =============================== END OF FILES CHECKED IN OUT REPORT ===================================== */
		
		/* =============================== MAKE CASES EVIDENCE NOT COLLECTED ===================================== */
		private function makeCasesNotCollectedReport():void {
			// Change button to say generating
			reportsView.generateButton.label = "Generating";
			layout.notificationBar.showProcess("Generating Report...");
			AppModel.getInstance().getCasesNotCollection(gotCasesNotCollected);
		}
		private function gotCasesNotCollected(status:Boolean, eraCaseArray:Array=null):void {
			if(!status) {
				reportsView.generateButton.label = "Generate";
				layout.notificationBar.showError("Failed to generate Report");
				return;
			}
			layout.notificationBar.showGood("Finished Generating");
			reportsView.generateButton.label = "View";
			
			var p:PDF = makeReportWithHeader("Cases with Evidence Not Collected");
			
		
			p.setFont(myriadFont, 10);
			for each(var eraCase:Model_ERACase in eraCaseArray) {

				p.writeText(10, "RM Code: " + eraCase.rmCode + "\n");
				p.writeText(10, "Title: " + eraCase.title + "\n");
				p.writeText(10, "Researchers:\n");
				for each(var caseResearcher:Model_ERAUser in eraCase.researchersArray) {
					p.writeText(12, caseResearcher.lastName + ", " + caseResearcher.firstName + "\n");
				}
				p.writeText(12, "\n");
			}
			p.writeText(12, "\n\n");
			reportData = p.save( Method.LOCAL );
		}
		/* =============================== END OF MAKE CASES EVIDENCE NOT COLLECTED ===================================== */
		
		
		
		
		/* =============================== MAKE EXHIBITION CASES REPORT ===================================== */
		private function makeCasesInExhibitionReport():void {
			// Change button to say generating
			reportsView.generateButton.label = "Generating";
			layout.notificationBar.showProcess("Generating Report...");
			
			AppModel.getInstance().getCasesInExhibition(gotCasesInExhibition);
		}
		private function gotCasesInExhibition(status:Boolean, eraCaseArray:Array=null):void {
			if(!status) {
				reportsView.generateButton.label = "Generate";
				layout.notificationBar.showError("Failed to generate Report");
				return;
			}
			layout.notificationBar.showGood("Finished Generating");
			reportsView.generateButton.label = "View";
			
			var p:PDF = makeReportWithHeader("Cases in Exhibition");
			
			p.setFont(myriadFont, 10);
			for each(var eraCase:Model_ERACase in eraCaseArray) {
				p.writeText(10, "RM Code: " + eraCase.rmCode + "\n");
				p.writeText(10, "Title: " + eraCase.title + "\n");
				p.writeText(10, "Researchers:\n");
				for each(var caseResearcher:Model_ERAUser in eraCase.researchersArray) {
					p.writeText(12, caseResearcher.lastName + ", " + caseResearcher.firstName + "\n");
				}
				p.writeText(12, "\n");
			}
			p.writeText(12, "\n\n");
			reportData = p.save( Method.LOCAL );
		}
		/* =============================== END OF MAKE EXHIBITION CASES REPORT ===================================== */
		
		/* =============================== MAKE RESEARCHERS SCHOOL REPORT ===================================== */
		private function makeResearcherSchoolReport():void {
			// need to get the researchers from database
			reportsView.generateButton.label = "Generating";
			layout.notificationBar.showProcess("Generating Report...");
			AppModel.getInstance().getResearchersInSchools(new Array("MECA", "SOD"), gotResearchers);
		}
		private function gotResearchers(status:Boolean, researcherSchoolObject:Object=null):void {
			if(!status) {
				reportsView.generateButton.label = "Generate";
				layout.notificationBar.showError("Failed to generate Report");
				return;
			}
			layout.notificationBar.showGood("Finished Generating");
			reportsView.generateButton.label = "View";
			
			trace("got researchers", researcherSchoolObject);
			
			var p:PDF = makeReportWithHeader("Researchers Per School");
			
			// Lets put in the school now
			for(var school:String in researcherSchoolObject) {
				trace("writing school", school);
				p.setFont(myriadFont, 12);
				p.writeText(12, school + "\n");
				
				p.setFont(myriadFont, 10);
				for each(var researcher:Model_ERAUser in researcherSchoolObject[school]) {
					
					var hello:String = researcher.username + ": " + researcher.lastName + ", " + researcher.firstName + "\n";
					trace("writing researcher", hello);
					p.writeText(10, hello);
				}
				p.addPage();
			}
			
			reportData = p.save( Method.LOCAL );
			
		}
		/* =============================== END OF MAKE RESEARCHERS SCHOOL REPORT ===================================== */
		
		private function makeReportWithHeader(title:String):PDF {
			var p:PDF = new PDF(Orientation.PORTRAIT, Unit.MM, Size.A4);
			
			p.addPage();
			
			// Make the header
			var genDate:Date = new Date();
			
			var userDetails:Model_ERAUser = Auth.getInstance().getUserDetails();
			
			p.setTitle(title);
			// Lets put a heading
			p.setFont(myriadFont, 24, true);
			p.writeText(24, title + "\n");
			
			// Write in the user
			p.setFont(myriadFont, 8);
			p.writeText(8, "Date: " + genDate.getDay() + "/" + genDate.getMonth() + "/" + genDate.getFullYear() + "\n");
			p.writeText(8, "By " + userDetails.firstName + " " + userDetails.lastName + "\n\n");
			
			return p;
		}
		
		//When the controller is destroyed/switched
		override public function dealloc():void {
			super.dealloc();
		}
	}
}