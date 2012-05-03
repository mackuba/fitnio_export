# Fitnio export

This tool downloads your activity data from the sports tracking webapp [Fitnio.com](http://fitnio.com). You can use this if you want to back up your data or move it elsewhere (e.g. to [RunKeeper](http://runkeeper.com)). It exports the activity data in [GPX format](https://en.wikipedia.org/wiki/GPS_eXchange_Format), a standard format for representing GPS routes.

## Requirements

You need to have Ruby installed on your machine (any recent version will do).

## Installation

Just install the gem:

    gem install fitnio_export

## Running

Run the fitnio_export command:

    fitnio_export

The script will ask you for your email and password, and then will try to download your dashboard page with a list of activities. If it works, it will download your activities one by one and will save the converted data as files named e.g. `fitnio-2012-05-03-1730.gpx` in the current directory.

## Importing into RunKeeper

I'm not aware of any mass import feature in RunKeeper, so you'll have to import the activities manually one by one. Click "Post new activity", choose activity type, then choose "Import Map" and choose the generated GPX file. You should see the imported map now - if it looks ok, press "Next" and save the map.

## Credits

* Fitnio.com is © Fitnio LLC
* RunKeeper is © FitnessKeeper Inc.
* fitnio_export is © Jakub Suder and licensed under MIT license
