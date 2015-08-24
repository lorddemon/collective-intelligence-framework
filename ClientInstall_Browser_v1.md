**Table of Contents**


# Introduction #

This extension for Google Chrome/Firefox allows you to query CIF servers and get formatted results in your browser. It also allows new data to be submitted directly via the API.

  * Supports multiple API keys and multiple servers
  * Submit [data types](DataTypes.md) points directly to the server without creating a feed
  * libcif **NOT** required
  * Right click to search any highlighted text
  * Search comma, space and return delimited lists
  * "Related Event" links take you to source indicator
  * Click to sort by columns in results
  * Search filters

# Installation #
## Google Chrome ##
  1. From Google Chrome, click [here](https://chrome.google.com/webstore/detail/collective-intelligence-f/bimiihlcdmbjjpbmnkiaaiolfneljdne) for the plugin
  1. Install the plug-in. (_Note: You will receive a warning that the plugin as access to your data on all websites. The plugin needs to be able to contact custom servers that are specified and the 'tabs' permission is required to switch to an existing query tab.)_
  1. Right click CIF button (top right) -> **Options**
  1. Enter your **Nickname** for the host you're connecting to (e.g. _CIF-West_)
  1. Enter your URL (e.g. _https://example.org/api/_)
  1. Enter your [API key](Tools_cif_apikeys.md)
  1. Click test connection  (_Note: using a self-signed certificate, the URL needs to be opened in a separate tab to accept the certificate before this will succeed._)
  1. Click **Save** and close the settings page.

## Firefox ##
  1. From Firefox, download the [latest cif-client-firefox release](https://github.com/collectiveintel/cif-client-chrome/releases). Drag the downloaded file into the browser to install it.
  1. Right click CIF button (top right) -> **Settings**
  1. Enter your **Nickname** for the host you're connecting to (e.g. _CIF-West_)
  1. Enter your URL (e.g. _https://example.org/api/_)
  1. Enter your [API key](Tools_cif_apikeys.md)
  1. Click test connection  (_Note: If you are using a self-signed certificate, you will need to open the URL in a separate tab to accept the certificate before this will succeed._)
  1. Click **Save** and close the settings page.

# Usage #
## Running a Query ##
  1. Left click the CIF button
  1. Paste a [data type](DataTypes.md) into the query text box
  1. Click Submit
> OR
  1. Highlight a [data type](DataTypes.md)
  1. Right-click the highlighted text
  1. Click **Collective Intelligence Framework** and then **Query CIF Server for...**

The query page will parse out comma-separated, space-separated, new-line separated queries and a mix of all three.

## Filtering Results ##
Click the plus next to the query to view the possible filters for the query. The results can be filtered by the following attributes using the "Adv Filters" link:
  * **confidence**: sets a minimum confidence that the incident must meet to be returned (numeric value between 0 and 100).
  * **limit**: numeric value that limits the total number of records that will come back.

## Adding Data ##
  1. Left click the CIF button
  1. Click **Data Submission Form**
  1. Paste in one or more [data type](DataTypes.md) into Data
> OR
  1. Highlight a [data type](DataTypes.md)
  1. Right-click the highlighted text
  1. Click **Collective Intelligence Framework** and then **Add 'x' to CIF...**

## Notes on Adding Data ##
  * The data page will also parse out comma-separated, space-separated, new-line separated queries. A preview of the entries is shown on the right of the data entry page.
  * The API key you use requires write privileges, which are not given to a key by default. Use the **cif\_apikeys** tool with the **-w** option to grant a key write access.
  * Data types can't be mixed. (e.g. No URL's and email address in the same submission)
  * Values for confidence can be modified on the options page.
  * By adding a data point using this method, it will only be entered once so it will fall out of a feed after the **max\_days** value for that feed. (It will still show up in queries for that specific item.)