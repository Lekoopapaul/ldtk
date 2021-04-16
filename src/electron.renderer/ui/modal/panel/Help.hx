package ui.modal.panel;

class Help extends ui.modal.Panel {
	public function new() {
		super();

		linkToButton("button.showHelp");

		loadTemplate( "help", "helpPanel", {
			appUrl: Const.HOME_URL,
			discordUrl: Const.DISCORD_URL,
			docUrl: Const.DOCUMENTATION_URL,
			app: Const.APP_NAME,
			ver: Const.getAppVersion(),
		});

		jContent.find("dt").each( function(idx, e) {
			var jDt = new J(e);
			JsTools.parseKeysIn( jDt );
		});
	}

}
