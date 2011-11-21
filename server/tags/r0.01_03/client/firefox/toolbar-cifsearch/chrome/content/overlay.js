function CIFBarSearch(event){
    // https://developer.mozilla.org/en/Code_snippets/Preferences
    // Get the "extensions.myext." branch
    var prefs = Components.classes["@mozilla.org/preferences-service;1"].getService(Components.interfaces.nsIPrefService);
    prefs = prefs.getBranch("extensions.cifsearch.");
    
    var apikey  = prefs.getCharPref("strapikey");
    var host    = prefs.getCharPref("strhost");

    var query = document.getElementById("query").value;
    var REST = host + '/' + encodeURI(query) + "?apikey=" + apikey;
    //alert(REST);
    window._content.document.location  = host + '/' + encodeURI(query) + "?apikey=" + apikey;    
}
