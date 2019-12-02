# Core-Data-SPoT
Flickr photos viewer for Stanford CS193p course using CoreData for the local database

The Flickr API key is stored in a JSON configuration file that is located outside of the project.
This file must be added to the application bundle using Xcode Target -> Build Phases -> Copy to Bundle
in the project settings.

The config file should be named `flickr_config.json`

The format of the config file is as follows:
```
{
    "keys":
    {
        "api_key": "your_flickr_api_key_here"
    }
}
```
