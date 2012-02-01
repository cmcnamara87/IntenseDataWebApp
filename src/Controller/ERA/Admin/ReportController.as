package Controller.ERA.Admin
{
	import Controller.AppController;
	import Controller.Utilities.AssetLookup;
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
	
	import mx.collections.ArrayCollection;
	
	import org.alivepdf.colors.RGBColor;
	import org.alivepdf.data.Grid;
	import org.alivepdf.data.GridColumn;
	import org.alivepdf.events.PageEvent;
	import org.alivepdf.fonts.CodePage;
	import org.alivepdf.fonts.CoreFont;
	import org.alivepdf.fonts.EmbeddedFont;
	import org.alivepdf.fonts.FontFamily;
	import org.alivepdf.fonts.IFont;
	import org.alivepdf.images.ColorSpace;
	import org.alivepdf.layout.Align;
	import org.alivepdf.layout.Mode;
	import org.alivepdf.layout.Orientation;
	import org.alivepdf.layout.Position;
	import org.alivepdf.layout.Resize;
	import org.alivepdf.layout.Size;
	import org.alivepdf.layout.Unit;
	import org.alivepdf.pdf.PDF;
	import org.alivepdf.saving.Download;
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
		
		private var newPdf:PDF;
		
		[Embed(source="Assets/Template/report_header.jpg", mimeType="application/octet-stream")]
		public static var report_header:Class;
		
		
		public static const REPORT_RESEARCHERS_IN_SCHOOLS:String = "REPORT_RESEARCHERS_IN_SCHOOLS";
		public static const REPORT_CASES_IN_EXHIBITION:String = "REPORT_CASES_IN_EXHIBITION";
		public static const REPORT_CASES_DOWNLOADED:String = "REPORT_CASES_DOWNLOADED";
		public static const REPORT_CASES_NOT_COLLECTED:String = "REPORT_CASES_NOT_COLLECTED";
		public static const REPORT_CHECKED_OUT:String = "REPORT_CHECKED_OUT";
		public static const REPORT_RESEARCHERS_NOT_INVOLVED:String = "REPORT_RESEARCHERS_NO_ACTIVITY";
		public static const REPORT_EVIDENCE_NOT_UPLOADED:String = "REPORT_EVIDENCE_NOT_UPLOADED";
		public static const REPORT_CASES_WITH_EVIDENCE_UNDER_REVIEW:String = "REPORT_CASES_WITH_EVIDENCE_UNDER_REVIEW";
		
		// review lab: cases with evidence under review - list cases with any evidence in review lab
		// forensic lab: evidence not returned
		
		public function ReportController()
		{
			reportsView = new ReportsView();
			view = reportsView;
			super();
		}
		
		override public function init():void {
			layout.header.unhighlightAllButtons();
			layout.header.reportButton.setStyle("chromeColor", "0x000000");
			
			// Create our font
			myriadFont = new EmbeddedFont(new fontStream(), new afmStream(), CodePage.CP1254);
			
			setupEventListeners();
		}
		
		private function setupEventListeners():void {
			reportsView.generateButton.addEventListener(MouseEvent.CLICK, generateReport, false, 0, true);
			reportsView.reportDropdown.addEventListener(Event.CHANGE, reportDropdownChanged, false, 0, true);
		}
		
		public static function getReportPrettyName(reportType:String, download:Boolean=false):String {
			// we need to include download or display, because report downloading does not allow colons
			switch(reportType) {
				case REPORT_RESEARCHERS_IN_SCHOOLS:
					return "CIF ERA " + AppController.currentEraProject.year + ": List of researchers";
					break;
				case REPORT_CASES_IN_EXHIBITION:
					if(download) {
						return "Exhibition Room - Cases ready to be exhibited";
					} else {
						return "Exhibition Room: Cases ready to be exhibited";
					}
					break;
				case REPORT_CASES_DOWNLOADED:
					if(download) {
						return "Exhibition Room - Cases Downloaded";
					} else {
						return "Exhibition Room: Cases Downloaded";
					}
					break;
				case REPORT_CASES_NOT_COLLECTED:
					if(download) {
						return "Evidence Manager - Evidence not yet collected";
					} else {
						return "Evidence Manager: Evidence not yet collected";
					}
					break;
				case REPORT_CHECKED_OUT:
					if(download) {
						return "Forensic Lab - Evidence not returned to the Forensic Lab";
					} else {
						return "Forensic Lab: Evidence not returned to the Forensic Lab";
					}
					break;
				case REPORT_RESEARCHERS_NOT_INVOLVED:
					if(download) {
						return "Evidence Box Review Lab - Cases without researcher activity";
					} else {
						return "Evidence Box/Review Lab: Cases without researcher activity";
					}
					break;
				case REPORT_EVIDENCE_NOT_UPLOADED:
					if(download) {
						return "Evidence Box - Cases without any evidence";
					} else {
						return "Evidence Box: Cases without any evidence";
					}
					break;
				case REPORT_CASES_WITH_EVIDENCE_UNDER_REVIEW:
					if(download) {
						return "Review Lab - Cases with evidence under review";
					} else {
						return "Review Lab: Cases with evidence under review";
					}
					break;
			}
			return "";
		}
		
		private function reportDropdownChanged(e:Event):void {
			selectedReport = "";
			reportData = null;
			reportsView.generateButton.label = "Generate Report";
		}
		
		/**
		 * Cancel downloading a report,  
		 * @param e
		 * 
		 */		
		private function saveReportCancelled(e:Event):void {
			// stuff for php later
//			reportsView.generateButton.label = "Generate Report";
		}
		private function saveComplete(e:Event):void {
			reportsView.generateButton.label = "Generate Report";
			reportsView.reportDropdown.selectedIndex = -1;
		}
		
		/**
		 * Generate a report or download it if it has already been generated 
		 * @param e
		 * 
		 */		
		private function generateReport(e:MouseEvent):void {
			
			if(reportsView.reportDropdown.selectedIndex == -1) return;
			
			if(selectedReport != "" && reportData != null) {
				// we have a selected report, and data for it
				// so show it
				var newReport:FileReference = new FileReference();
				newReport.addEventListener(Event.CANCEL, saveReportCancelled);
				newReport.addEventListener(Event.COMPLETE, saveComplete);
				
				var currentDate:Date = new Date();
				var dateString:String = currentDate.getDate() + "_" + (currentDate.getMonth()+1) + "_" + currentDate.getFullYear();
				
				trace("pdf stuff", ReportController.getReportPrettyName(selectedReport, true) + "_" + dateString + ".pdf");
				
				
//				newReport.save(Method.REMOTE, "http://123.100.147.12/print_pdf.php",Download.INLINE ,"drawing.pdf" );
				
//				newReport.save(reportData, ReportController.getReportPrettyName(selectedReport, true) + "_" + dateString + ".pdf");
				
				// clear it after downloading
				
				
				return;
			}
			
			
			// making a new report
			// find out what the selected report is
			selectedReport = reportsView.reportDropdown.selectedItem.data;
			
			switch(selectedReport) {
				case REPORT_RESEARCHERS_IN_SCHOOLS:
					makeResearcherSchoolReport();
					break;
				case REPORT_CASES_IN_EXHIBITION:
					makeCasesInExhibitionReport();
					break;
				case REPORT_CASES_DOWNLOADED:
					makeCasesDownloadedReport();
					break;
				case REPORT_CASES_NOT_COLLECTED:
					makeCasesNotCollectedReport();
					break;
				case REPORT_CHECKED_OUT:
					makeFilesCheckedInOutReport();
					break;
				case REPORT_RESEARCHERS_NOT_INVOLVED:
					makeCasesResearchersNotInvolved();
					break;
				case REPORT_EVIDENCE_NOT_UPLOADED:
					makeCasesEvidenceNotUploaded();
					break;
				case REPORT_CASES_WITH_EVIDENCE_UNDER_REVIEW:
					makeCasesWithEvidenceUnderReview();
					break;
			}			
		}
		
		private function sendPDFtoPHP(p:PDF):void {
			var currentDate:Date = new Date();
			var dateString:String = currentDate.getDate() + "_" + (currentDate.getMonth()+1) + "_" + currentDate.getFullYear();
			trace("pdf stuff", ReportController.getReportPrettyName(selectedReport, true) + "_" + dateString + ".pdf");
			
			p.save(Method.REMOTE, "http://" + Recensio_Flex_Beta.serverAddress + "/print_pdf.php", Download.INLINE , ReportController.getReportPrettyName(selectedReport, true) + "_" + dateString + ".pdf");
		}
		
		/* =============================== MAKE CASSES WITH EVIDENCE UNDER REVIEW REPORT ===================================== */
		private function makeCasesWithEvidenceUnderReview():void {
			// Change button to say Generating...
			reportsView.generateButton.label = "Generating...";
			layout.notificationBar.showProcess("Generating Report...");
			AppModel.getInstance().getCasesWithEvidenceUnderReview(gotCasesWithEvidenceUnderReview);
		}
		private function gotCasesWithEvidenceUnderReview(status:Boolean, eraCaseFileArray:Array=null):void {
			if(!status) {
				reportsView.generateButton.label = "Generate";
				layout.notificationBar.showError("Failed to generate Report");
				return;
			}
			layout.notificationBar.showGood("Finished Generating");
			reportsView.generateButton.label = 'Open Report';
			
			var p:PDF = makeReportWithHeader(getReportPrettyName(REPORT_CASES_WITH_EVIDENCE_UNDER_REVIEW));
			
			var dp:ArrayCollection = new ArrayCollection();
			
			p.setFont(myriadFont, 10);
			p.textStyle( new RGBColor ( 0x000000) );
			
			for each(var eraCaseFileObject:Object in eraCaseFileArray) {
				var eraCase:Model_ERACase = eraCaseFileObject.eraCase;
				var fileArray:Array = eraCaseFileObject.files;
				
				var researchersString:String = "";
				for each(var caseResearcher:Model_ERAUser in eraCase.researchersArray) {
					researchersString += caseResearcher.lastName + ", " + caseResearcher.firstName + "\n";
				}
				
				var filesString:String = "";
				for each(var file:Model_ERAFile in fileArray) {
					filesString += file.title + "\n";
				}
				trace("fileString is", filesString);
				// add a table row
				dp.addItem( { rmCode : eraCase.rmCode, title : eraCase.title, researchers : researchersString, files: filesString } );
			}
			
			// create columns to specify the column order
			// 155 pixels wide?
			var gridColumnAge:GridColumn = new GridColumn("RM Code", "rmCode", 30, Align.LEFT, Align.LEFT);
			var gridColumnEmail:GridColumn = new GridColumn("Title", "title", 40, Align.LEFT, Align.LEFT);
			var gridColumnFirstName:GridColumn = new GridColumn("Researchers", "researchers", 40, Align.LEFT, Align.LEFT);
			var gridColumnLastName:GridColumn = new GridColumn("Files", "files", 80, Align.LEFT, Align.LEFT);
			
			// create a columns Array
			// it determines the order shown in the PDF
			var columns:Array = new Array (gridColumnAge, gridColumnEmail, gridColumnFirstName, gridColumnLastName);
			
			// create a Grid object as usual
			var grid:Grid = new Grid( dp.toArray(), 200, 120, new RGBColor ( 0xAAAAAA ), new RGBColor (0xCCCCCC), true, new RGBColor(0x666666), 1, null, columns );
			
			p.addGrid(grid);
//			reportData = p.save( Method.LOCAL );
			sendPDFtoPHP(p);
		}
		
		/* =============================== END OF FILES CHECKED IN OUT REPORT ===================================== */
		
			
		private function makeCasesEvidenceNotUploaded():void {
			// Change button to say Generating...
			reportsView.generateButton.label = "Generating...";
			layout.notificationBar.showProcess("Generating Report...");
			AppModel.getInstance().getCasesWithoutEvidence(gotCasesEvidenceNotUploaded);
		}
		private function gotCasesEvidenceNotUploaded(status:Boolean, eraCaseArray:Array=null):void {
			if(!status) {
				reportsView.generateButton.label = "Generate";
				layout.notificationBar.showError("Failed to generate Report");
				return;
			}
			layout.notificationBar.showGood("Finished Generating");
			reportsView.generateButton.label = 'Open Report';
			
			var p:PDF = makeReportWithHeader(getReportPrettyName(REPORT_EVIDENCE_NOT_UPLOADED));
			
			var dp:ArrayCollection = new ArrayCollection();
			
			p.setFont(myriadFont, 10);
			p.textStyle( new RGBColor ( 0x000000) );
			
			for each(var eraCase:Model_ERACase in eraCaseArray) {
				// get all the researchers into a string
				var researchersString:String = "";
				for each(var caseResearcher:Model_ERAUser in eraCase.researchersArray) {
					researchersString += caseResearcher.lastName + ", " + caseResearcher.firstName + "\n";
				}
				
				// add a table row
				dp.addItem( { rmCode : eraCase.rmCode, title : eraCase.title, researchers : researchersString } );
			}
			
			// create columns to specify the column order
			// 155 pixels wide?
			var gridColumnAge:GridColumn = new GridColumn("RM Code", "rmCode", 30, Align.LEFT, Align.LEFT);
			var gridColumnEmail:GridColumn = new GridColumn("Title", "title", 115, Align.LEFT, Align.LEFT);
			var gridColumnFirstName:GridColumn = new GridColumn("Researchers", "researchers", 40, Align.LEFT, Align.LEFT);
			//			var gridColumnLastName:GridColumn = new GridColumn("Last Name", "lastName", 45, Align.LEFT, Align.LEFT);
			
			// create a columns Array
			// it determines the order shown in the PDF
			var columns:Array = new Array (gridColumnAge, gridColumnEmail, gridColumnFirstName);
			
			// create a Grid object as usual
			var grid:Grid = new Grid( dp.toArray(), 200, 120, new RGBColor ( 0xAAAAAA ), new RGBColor (0xCCCCCC), true, new RGBColor(0x666666), 1, null, columns );
			
			p.addGrid(grid);
			
//			reportData = p.save( Method.LOCAL );
			sendPDFtoPHP(p);
		}
		
		/* =============================== MAKE CASES EVIDENCE NOT COLLECTED ===================================== */
		private function makeCasesResearchersNotInvolved():void {
			// Change button to say Generating...
			reportsView.generateButton.label = "Generating...";
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
			reportsView.generateButton.label = 'Open Report';
			
			var p:PDF = makeReportWithHeader(getReportPrettyName(REPORT_RESEARCHERS_NOT_INVOLVED));

			var dp:ArrayCollection = new ArrayCollection();
			
			p.setFont(myriadFont, 10);
			p.textStyle( new RGBColor ( 0x000000) );
			
			for each(var eraCase:Model_ERACase in eraCaseArray) {
				// get all the researchers into a string
				var researchersString:String = "";
				for each(var caseResearcher:Model_ERAUser in eraCase.researchersArray) {
					researchersString += caseResearcher.lastName + ", " + caseResearcher.firstName + "\n";
				}
				
				// add a table row
				dp.addItem( { rmCode : eraCase.rmCode, title : eraCase.title, researchers : researchersString } );
			}
			
			// create columns to specify the column order
			// 155 pixels wide?
			var gridColumnAge:GridColumn = new GridColumn("RM Code", "rmCode", 30, Align.LEFT, Align.LEFT);
			var gridColumnEmail:GridColumn = new GridColumn("Title", "title", 115, Align.LEFT, Align.LEFT);
			var gridColumnFirstName:GridColumn = new GridColumn("Researchers", "researchers", 40, Align.LEFT, Align.LEFT);
//			var gridColumnLastName:GridColumn = new GridColumn("Last Name", "lastName", 45, Align.LEFT, Align.LEFT);
			
			// create a columns Array
			// it determines the order shown in the PDF
			var columns:Array = new Array (gridColumnAge, gridColumnEmail, gridColumnFirstName);
			
			// create a Grid object as usual
			var grid:Grid = new Grid( dp.toArray(), 200, 120, new RGBColor ( 0xAAAAAA ), new RGBColor (0xCCCCCC), true, new RGBColor(0x666666), 1, null, columns );
			
			p.addGrid(grid);
			
			sendPDFtoPHP(p);
		}
		/* =============================== END OF MAKE CASES EVIDENCE NOT COLLECTED ===================================== */
		
		
		/* =============================== MAKE FILES CHECKED IN OUT REPORT ===================================== */
		private function makeFilesCheckedInOutReport():void {
			// Change button to say Generating...
			reportsView.generateButton.label = "Generating...";
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
			reportsView.generateButton.label = 'Open Report';
			
			var p:PDF = makeReportWithHeader(getReportPrettyName(REPORT_CHECKED_OUT));

			var dp:ArrayCollection = new ArrayCollection();
			
			p.setFont(myriadFont, 10);
			p.textStyle( new RGBColor ( 0x000000) );
			
			for each(var eraCaseFileObject:Object in eraCaseFileArray) {
				var eraCase:Model_ERACase = eraCaseFileObject.eraCase;
				var fileArray:Array = eraCaseFileObject.files;
				
				var researchersString:String = "";
				for each(var caseResearcher:Model_ERAUser in eraCase.researchersArray) {
					researchersString += caseResearcher.lastName + ", " + caseResearcher.firstName + "\n";
				}
				
				var filesString:String = "";
				for each(var file:Model_ERAFile in fileArray) {
					filesString += file.title + "(" + file.checkedOutUsername + ")\n";
				}
				trace("fileString is", filesString);
				// add a table row
				dp.addItem( { rmCode : eraCase.rmCode, title : eraCase.title, researchers : researchersString, files: filesString } );
			}
			
			// create columns to specify the column order
			// 155 pixels wide?
			var gridColumnAge:GridColumn = new GridColumn("RM Code", "rmCode", 30, Align.LEFT, Align.LEFT);
			var gridColumnEmail:GridColumn = new GridColumn("Title", "title", 40, Align.LEFT, Align.LEFT);
			var gridColumnFirstName:GridColumn = new GridColumn("Researchers", "researchers", 40, Align.LEFT, Align.LEFT);
			var gridColumnLastName:GridColumn = new GridColumn("Outstanding Evidence", "files", 80, Align.LEFT, Align.LEFT);
			
			// create a columns Array
			// it determines the order shown in the PDF
			var columns:Array = new Array (gridColumnAge, gridColumnEmail, gridColumnFirstName, gridColumnLastName);
			
			// create a Grid object as usual
			var grid:Grid = new Grid( dp.toArray(), 200, 120, new RGBColor ( 0xAAAAAA ), new RGBColor (0xCCCCCC), true, new RGBColor(0x666666), 1, null, columns );
			
			p.addGrid(grid);
			sendPDFtoPHP(p);
		}
		
		/* =============================== END OF FILES CHECKED IN OUT REPORT ===================================== */
		
		/* =============================== MAKE CASES EVIDENCE NOT COLLECTED ===================================== */
		private function makeCasesNotCollectedReport():void {
			// Change button to say Generating...
			reportsView.generateButton.label = "Generating...";
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
			reportsView.generateButton.label = 'Open Report';
			
			var p:PDF = makeReportWithHeader(getReportPrettyName(REPORT_CASES_NOT_COLLECTED));
		
			var dp:ArrayCollection = new ArrayCollection();
			
			p.setFont(myriadFont, 10);
			p.textStyle( new RGBColor ( 0x000000) );
			
			for each(var eraCase:Model_ERACase in eraCaseArray) {

				// get all the researchers into a string
				var researchersString:String = "";
				for each(var caseResearcher:Model_ERAUser in eraCase.researchersArray) {
					researchersString += caseResearcher.lastName + ", " + caseResearcher.firstName + "\n";
				}
				
				// add a table row
				dp.addItem( { rmCode : eraCase.rmCode, title : eraCase.title, researchers : researchersString } );
			}
			
			// create columns to specify the column order
			// 155 pixels wide?
			var gridColumnAge:GridColumn = new GridColumn("RM Code", "rmCode", 30, Align.LEFT, Align.LEFT);
			var gridColumnEmail:GridColumn = new GridColumn("Title", "title", 120, Align.LEFT, Align.LEFT);
			var gridColumnFirstName:GridColumn = new GridColumn("Researchers", "researchers", 40, Align.LEFT, Align.LEFT);
			
			// create a columns Array
			// it determines the order shown in the PDF
			var columns:Array = new Array (gridColumnAge, gridColumnEmail, gridColumnFirstName);
			
			// create a Grid object as usual
			var grid:Grid = new Grid( dp.toArray(), 200, 120, new RGBColor ( 0xAAAAAA ), new RGBColor (0xCCCCCC), true, new RGBColor(0x666666), 1, null, columns );
			
			p.addGrid(grid);
			
			sendPDFtoPHP(p);
		}
		/* =============================== END OF MAKE CASES EVIDENCE NOT COLLECTED ===================================== */
		
		
		private function makeCasesDownloadedReport():void {
			// Change button to say Generating...
			reportsView.generateButton.label = "Generating...";
			layout.notificationBar.showProcess("Generating Report...");
			
			AppModel.getInstance().getCasesInExhibition(gotCasesDownloaded);
		}
		private function gotCasesDownloaded(status:Boolean, eraCaseArray:Array=null):void {
			if(!status) {
				reportsView.generateButton.label = "Generate";
				layout.notificationBar.showError("Failed to generate Report");
				return;
			}
			layout.notificationBar.showGood("Finished Generating");
			reportsView.generateButton.label = 'Open Report';
			
			var p:PDF = makeReportWithHeader(getReportPrettyName(REPORT_CASES_DOWNLOADED));
			
			var dp:ArrayCollection = new ArrayCollection();
			
			p.setFont(myriadFont, 10);
			p.textStyle( new RGBColor ( 0x000000) );
			
			for each(var eraCase:Model_ERACase in eraCaseArray) {
				// get all the researchers into a string
				var researchersString:String = "";
				for each(var caseResearcher:Model_ERAUser in eraCase.researchersArray) {
					researchersString += caseResearcher.lastName + ", " + caseResearcher.firstName + "\n";
				}
				
				// add a table row
				dp.addItem( { rmCode : eraCase.rmCode, title : eraCase.title, researchers : researchersString } );
			}
			
			// create columns to specify the column order
			// 155 pixels wide?
			var gridColumnAge:GridColumn = new GridColumn("RM Code", "rmCode", 30, Align.LEFT, Align.LEFT);
			var gridColumnEmail:GridColumn = new GridColumn("Title", "title", 120, Align.LEFT, Align.LEFT);
			var gridColumnFirstName:GridColumn = new GridColumn("Researchers", "researchers", 40, Align.LEFT, Align.LEFT);
			//			var gridColumnLastName:GridColumn = new GridColumn("Last Name", "lastName", 45, Align.LEFT, Align.LEFT);
			
			// create a columns Array
			// it determines the order shown in the PDF
			var columns:Array = new Array (gridColumnAge, gridColumnEmail, gridColumnFirstName);
			
			// create a Grid object as usual
			var grid:Grid = new Grid( dp.toArray(), 200, 120, new RGBColor ( 0xAAAAAA ), new RGBColor (0xCCCCCC), true, new RGBColor(0x666666), 1, null, columns );
			
			p.addGrid(grid);
			
			sendPDFtoPHP(p);
		}
		
		
		/* =============================== MAKE EXHIBITION CASES REPORT ===================================== */
		private function makeCasesInExhibitionReport():void {
			// Change button to say Generating...
			reportsView.generateButton.label = "Generating...";
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
			reportsView.generateButton.label = 'Open Report';
			
			var p:PDF = makeReportWithHeader(getReportPrettyName(REPORT_CASES_IN_EXHIBITION));
			
			var dp:ArrayCollection = new ArrayCollection();
			
			p.setFont(myriadFont, 10);
			p.textStyle( new RGBColor ( 0x000000) );
			
			for each(var eraCase:Model_ERACase in eraCaseArray) {
				// get all the researchers into a string
				var researchersString:String = "";
				for each(var caseResearcher:Model_ERAUser in eraCase.researchersArray) {
					researchersString += caseResearcher.lastName + ", " + caseResearcher.firstName + "\n";
				}
				
				// add a table row
				dp.addItem( { rmCode : eraCase.rmCode, title : eraCase.title, researchers : researchersString } );
			}
			
			// create columns to specify the column order
			// 155 pixels wide?
			var gridColumnAge:GridColumn = new GridColumn("RM Code", "rmCode", 30, Align.LEFT, Align.LEFT);
			var gridColumnEmail:GridColumn = new GridColumn("Title", "title", 120, Align.LEFT, Align.LEFT);
			var gridColumnFirstName:GridColumn = new GridColumn("Researchers", "researchers", 40, Align.LEFT, Align.LEFT);
			//			var gridColumnLastName:GridColumn = new GridColumn("Last Name", "lastName", 45, Align.LEFT, Align.LEFT);
			
			// create a columns Array
			// it determines the order shown in the PDF
			var columns:Array = new Array (gridColumnAge, gridColumnEmail, gridColumnFirstName);
			
			// create a Grid object as usual
			var grid:Grid = new Grid( dp.toArray(), 200, 120, new RGBColor ( 0xAAAAAA ), new RGBColor (0xCCCCCC), true, new RGBColor(0x666666), 1, null, columns );
			
			p.addGrid(grid);
			
			sendPDFtoPHP(p);
		}
		/* =============================== END OF MAKE EXHIBITION CASES REPORT ===================================== */
		
		/* =============================== MAKE RESEARCHERS SCHOOL REPORT ===================================== */
		private function makeResearcherSchoolReport():void {
			// need to get the researchers from database
			reportsView.generateButton.label = "Generating...";
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
			reportsView.generateButton.label = 'Open Report';
			
			trace("got researchers", researcherSchoolObject);
			
			var p:PDF = makeReportWithHeader(getReportPrettyName(REPORT_RESEARCHERS_IN_SCHOOLS));
			
			var dp:ArrayCollection = new ArrayCollection();
			
			p.setFont(myriadFont, 10);
			p.textStyle( new RGBColor ( 0x000000) );
			
			// Lets put in the school now
			for(var school:String in researcherSchoolObject) {
				var researchersString:String = "";
				for each(var researcher:Model_ERAUser in researcherSchoolObject[school]) {
					researchersString += researcher.lastName + ", " + researcher.firstName + "\n";
				}
					
				// add a table row
				dp.addItem( { schoolTitle : school, researchers : researchersString } );
			}
			
			var gridColumnAge:GridColumn = new GridColumn("School", "schoolTitle", 30, Align.LEFT, Align.LEFT);
			var gridColumnEmail:GridColumn = new GridColumn("Researchers", "researchers", 155, Align.LEFT, Align.LEFT);
			//			var gridColumnLastName:GridColumn = new GridColumn("Last Name", "lastName", 45, Align.LEFT, Align.LEFT);
			
			// create a columns Array
			// it determines the order shown in the PDF
			var columns:Array = new Array (gridColumnAge, gridColumnEmail);
			
			// create a Grid object as usual
			var grid:Grid = new Grid( dp.toArray(), 200, 120, new RGBColor ( 0xAAAAAA ), new RGBColor (0xCCCCCC), true, new RGBColor(0x666666), 1, null, columns );
			
			p.addGrid(grid);
			
			sendPDFtoPHP(p);
			
		}
		/* =============================== END OF MAKE RESEARCHERS SCHOOL REPORT ===================================== */
		
		private function makeReportWithHeader(title:String):PDF {
			newPdf = new PDF(Orientation.PORTRAIT, Unit.MM, Size.A4);
			newPdf.addEventListener(PageEvent.ADDED, addHeader);
			newPdf.addPage();
			
			
			newPdf.addText("hello!!!");
			// Make the header
			var genDate:Date = new Date();
			trace("today is", genDate);
			var userDetails:Model_ERAUser = Auth.getInstance().getUserDetails();
			
			newPdf.setTitle(title);
			// Lets put a heading
			newPdf.setFont(myriadFont, 24, true);
			newPdf.writeText(16, title + "\n");
			
			// Write in the user
			newPdf.setFont(myriadFont, 8);
			newPdf.writeText(4, "ERA Edition: " + AppController.currentEraProject.day + "/" + AppController.currentEraProject.month + "/" + AppController.currentEraProject.year + "\n");
			newPdf.writeText(4, "Generated On: " + genDate.getDate() + "/" + (genDate.getMonth()+1) + "/" + genDate.getFullYear() + " " + genDate.getHours() + ":" + genDate.getMinutes()  + "\n");
			newPdf.writeText(8, "Generated By: " + userDetails.firstName + " " + userDetails.lastName + "\n\n");
			
			return newPdf;
		}
		
		private function addHeader(e:PageEvent):void {
			newPdf.writeText(12, "\n\n\n");
			newPdf.addImageStream(new report_header() as ByteArray, ColorSpace.DEVICE_RGB, new Resize(Mode.FIT_TO_PAGE, Position.LEFT), 0, 0);
			
		}
		//When the controller is destroyed/switched
		override public function dealloc():void {
			reportsView = null;
			super.dealloc();
		}
	}
}