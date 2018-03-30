import QtQml 2.0
import QOwnNotesTypes 1.0

import "markdown-it.js" as MarkdownIt

QtObject {
	property variant md;
	
	property string options;
	property string customStylesheet;

	property variant settingsVariables: [
		{
			"identifier": "options",
			"name": "Markdown-it options",
			"description": "For available options and default values see <a href='https://github.com/markdown-it/markdown-it/blob/master/lib/presets'>markdown-it presets</a>",
			"type": "text",
			"default":
"{"+"\n"+
"    //html:         false,        // Enable HTML tags in source"+"\n"+
"    //xhtmlOut:     false,        // Use '/' to close single tags (<br />)"+"\n"+
"    //breaks:       false,        // Convert '\\n' in paragraphs into <br>"+"\n"+
"    //langPrefix:   'language-',  // CSS language prefix for fenced blocks"+"\n"+
"    //linkify:      false,        // autoconvert URL-like texts to links"+"\n"+
""+"\n"+
"    // Enable some language-neutral replacements + quotes beautification"+"\n"+
"    //typographer:  false,"+"\n"+
""+"\n"+
"    // Double + single quotes replacement pairs, when typographer enabled,"+"\n"+
"    // and smartquotes on. Could be either a String or an Array."+"\n"+
"    //"+"\n"+
"    // For example, you can use '«»„“' for Russian, '„“‚‘' for German,"+"\n"+
"    // and ['«\\xA0', '\\xA0»', '‹\\xA0', '\\xA0›'] for French (including nbsp)."+"\n"+
"    //quotes: '\\u201c\\u201d\\u2018\\u2019', /* “”‘’ */"+"\n"+
""+"\n"+
"    // Highlighter function. Should return escaped HTML,"+"\n"+
"    // or '' if the source string is not changed and should be escaped externaly."+"\n"+
"    // If result starts with <pre... internal wrapper is skipped."+"\n"+
"    //"+"\n"+
"    // function (/*str, lang*/) { return ''; }"+"\n"+
"    //"+"\n"+
"    //highlight: null,"+"\n"+
""+"\n"+
"    //maxNesting:   100            // Internal protection, recursion limit"+"\n"+
"}"
		},
		{
            "identifier": "customStylesheet",
            "name": "Custom stylesheet",
            "description": "Please enter your custom stylesheet:",
            "type": "text",
            "default": null,
        },
	];
	
    function init() {
		
		var optionsObj = eval("("+options+")");
		md = new MarkdownIt.markdownit(optionsObj);
		
		//Allow file:// url scheme
		var validateLinkOrig = md.validateLink;
		var GOOD_PROTO_RE = /^(file):/;
		md.validateLink = function(url)
		{
			var str = url.trim().toLowerCase();
			return GOOD_PROTO_RE.test(str) ? true : validateLinkOrig(url);
		}
	}
	
    function noteToMarkdownHtmlHook(note, html) {
		
		var mdHtml = md.render(note.noteText);
		
		//Insert root folder in attachments and media relative urls
		var path = script.currentNoteFolderPath();
		if (script.platformIsWindows()) {
			path = "/" + path;
		}
		mdHtml = mdHtml.replace(new RegExp("href=\"file://attachments/", "gi"), "href=\"file://" + path + "/attachments/");
		mdHtml = mdHtml.replace(new RegExp("src=\"file://media/", "gi"), "src=\"file://" + path + "/media/");
		
		//Get original styles
		var head = html.match(new RegExp("<head>(?:.|\n)*?</head>"))[0];
		//Add custom styles
		head = head.replace("</style>", customStylesheet + "</style>");
		
		mdHtml = "<html>"+head+"<body>"+mdHtml+"</body></html>";
		
		return mdHtml;
    }
}
