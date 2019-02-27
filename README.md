# README

## What is CarbonApp

CarbonApp is a web application for displaying the world's carbon emmissions and population. The data is grouped by county and year.

The app provides both a browser-friendly user interface as well as API functionality for developers.

## Server

CarbonApp is currently hosted on Heroku in the address  
https://immense-crag-21709.herokuapp.com/.

## API

### Basics

Get a list of all countries in the world, as well as all other regions tracked by World Bank Group, with

    https://immense-crag-21709.herokuapp.com/api
.

To get a information about a specific country or region, you need its ISO2 code (called just "code" in the API). For example, to get information about the United States, whose code is "US", you must call

    https://immense-crag-21709.herokuapp.com/api/US
.

### Parameters

#### Global

The default format of all tables is JSON, but you can get them in XML with the `format=xml` tag. For example

    https://immense-crag-21709.herokuapp.com/api/US?format=xml
.

#### Specific country

By default, calling any specific country will yield data from the current year as well as the previous 20 years for a total of 21 entries. If however you only want data from one specific year, use the `year` parameter. Example:

    https://immense-crag-21709.herokuapp.com/api/US?year=2018
.

If you want a particular range of years, use both `from_year` and `to_year` tags. Example:

    https://immense-crag-21709.herokuapp.com/api/US?from_year=1999&to_year=2012
. These two tags will override the `year` tag if all three are present.
