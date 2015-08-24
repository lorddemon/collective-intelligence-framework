# Introduction #

This extension for Google Chrome/Firefox allows you to query CIF servers and get formatted results in your browser. It also allows new data to be submitted directly via the API.

# Features #
  * Right click to search any highlighted text
  * Search comma, space and return delimited lists
  * "Related Event" links take you to source indicator
  * Click to sort by columns in results
  * Search filters
  * Supports multiple API keys and multiple servers
  * **Submit** [data types](DataTypes.md) points directly to the server without creating a feed
  * No perl client required

Note: this is in the alpha stage of the software release cycle

# Documentation #
## Installation ##
### Google Chrome ###
  1. From Google Chrome, click [here](https://github.com/collectiveintel/cif-client-chrome/raw/master/CIF%20Chrome%20Extension.crx) for the plugin
  1. Install the plug-in.
    * (_Note: You will receive a warning that the plugin as access to your data on all websites. This is due to the fact that the plugin needs to be able to contact custom servers that you specify. The browsing activity warning is because of the 'tabs' permission, which is required to switch to an existing query tab.)_
  1. Right click CIF button (in the top right) -> **Options**
  1. Fill out **Nickname** (e.g. _CIF-West_)
  1. Fill out URL
    * (e.g. _https://example.org/api/_)
  1. Fill out [API key](Tools_cif_apikeys.md)
  1. Click test connection
    * (_Note: If you are using a self-signed certificate, you will need to open the URL in a separate tab to accept the certificate before this will succeed._)
  1. Click **Save** and close the settings page.

### Firefox ###
  1. From Firefox, click [here](https://github.com/collectiveintel/cif-client-chrome/blob/master/CIF-FFExtension.xpi?raw=true) to download the plugin. Drag the downloaded file into the browser to install it.
  1. Right click CIF button (in the top right) -> **Settings**
  1. Fill out **Nickname** (e.g. _CIF-West_)
  1. Fill out URL
    * (e.g. _https://example.org/api/_)
  1. Fill out [API key](Tools_cif_apikeys.md)
  1. Click test connection
    * (_Note: If you are using a self-signed certificate, you will need to open the URL in a separate tab to accept the certificate before this will succeed._)
  1. Click **Save** and close the settings page.

## Running a Query ##
  1. Left click the CIF button
  1. Paste a [data type](DataTypes.md) into the query text box
  1. Click Submit
> OR
  1. Highlight a [data type](DataTypes.md)
  1. Right-click the highlighted text
  1. Click **Collective Intelligence Framework** and then **Query CIF Server for...**

The query page will parse out comma-separated, space-separated, new-line separated queries and a mix of all three.

### Filtering Results ###

Click the plus next to the query to view the possible filters for the query. The results can be filtered by the following attributes:
  * **restriction**: filters records by their sharing restriction
  * **confidence**: sets a minimum confidence that the incident must meet to be returned (numeric value between 0 and 100).
  * **severity**: sets a minimum severity that the incident must meet
  * **limit**: numeric value that limits the total number of records that will come back.

## Adding Data ##
  1. Left click the CIF button
  1. Click **Data Submission Form**
  1. Paste in one or more [data type](DataTypes.md) into Data
> OR
  1. Highlight a [data type](DataTypes.md)
  1. Right-click the highlighted text
  1. Click **Collective Intelligence Framework** and then **Add 'x' to CIF...**
### Notes on Adding Data ###
  * The data page will also parse out comma-separated, space-separated, new-line separated queries. A preview of the entries is shown on the right of the data entry page.
  * The API key you use requires write privileges, which are not given to a key by default. Use the **cif\_apikeys** tool with the **-w** option to grant a key write access.
  * Data types can't be mixed. (e.g. No URL's and email address in the same submission)
  * Whitelist entries automatically result in a null severity.
  * Values for confidence can be modified on the options page.
  * By adding a data point using this method, it will only be entered once so it will fall out of a feed after the **max\_days** value for that feed. (It will still show up in queries for that specific item.)