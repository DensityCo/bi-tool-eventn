# eventn-density-mysql

## Overview

Example real-time BI Architecture using Density.io, Eventn.com, MySQL and Tableau.

This repository provides sample assets for deploying a realtime Business Intelligence architecture for Density doorway event data. This example demonstrates how
to aggregate Density data in real-time in to your own SQL environment and visualized with Tableau. This architecture consists of the following components:

* Density API - Initiates a real-time Webhook request upon each doorway event.
* Eventn Microservice - called upon each event for data processing and SQL connectivity.
* MySQL Database - used for storing and aggregating event data
* Tableau Dashboard - sample data visualizations

Benefits:

 * Setup and live in minutes
 * No Enterprise code to develop, deploy, scale or maintain
 * Business agility - easily change the schema or how the data is aggregated using SQL and JavaScript
 * Provides a simple solution for analysing Density data with other data sources inside the Enterprise


## Setup Guide

#### 1) Density.io API Key

Make sure you have access to a Density.io API token. These can be found inside the "Developer Tools" dashboard section: https://dashboard.density.io/#/dev/tokens. 


#### 2) Eventn Account

Eventn is an HTTP microservices platform that will be used for processing the Density event data and inserting in to a SQL database in real-time.

You can create an Eventn account in less than a minute for free at https://app.eventn.com/signup


#### 3) MySQL Database

The Density doorway event data will be stored inside of a MySQl database of your choice. Its worth noting that although this example is focused on MySQL, PostgreSQL, MS SQL Server and MariaDB are also supported by Eventn and hence can easily be substituted.

![RDS Database Options](/Docs/0_database_icons.png?raw=true "RDS Database Options")


If you do not have access to a public MySQL instance, you have other options:

1) Cloud Relational Database - Use a hosted database cloud service such as Amazon RDS (https://aws.amazon.com/rds/) or JawsDB (https://www.jawsdb.com/). Many such service offer free usage tiers.

2) Local Install - for temporary testing on a local desktop/laptop, it is also possible to install a database locally and connect from Eventn using Ngrok (https://ngrok.com/). See the Eventn setup guide here https://eventn.com/recipes/microservice-local-database-connection.


Once you have setup a MySQL instance, connect, create a database and run the `schema.sql` script using a SQL client of choice. This will create the sample schema and also setup a MySQL scheduled event that deletes any data stored in the `doorway_minute` table older than 12 hours. This is purely for performance reasons for tools such as Tableau but can of course be changed as needed. 


#### 4) Crete an Eventn Microservice

Once signed up at Eventn.com (https://app.eventn.com/signup), create a new microservice by clicking the plus icon from the top tight corner: 

![Eventn - Create Microservice](/Docs/1_eventn-create-service.png?raw=true "Eventn - Create Microservice")

This will create an internet facing REST endpoint. 


#### 5) Setup an Eventn Store Connection

In order to use an external database with an Eventn Microservice, it needs to be configured using your database credentials derived from step #3 above. Click on to the `Store` tab within the Eventn microservice, then select the `Create Store` button.


![Eventn - Create Store](/Docs/2_eventn-create-store.png?raw=true "Eventn - Create Store")


Enter the database connection string using your own credentials. For example, for MySQL the format is as follows:

`mysql://db_user:password@myhost:3306/databaseName`

Next, set a `name` property for that store within the form. This is the name that will be used inside of the Eventn function to reference the database store connection. In the example function provided, we have used the name `density`. If you do not use this name, you will need to update your functions accordingly (just find/replace `density`). You can also enter a `default_table` value of `doorway_hourly`.

Now that your custom store is configured, you can test it. Navigate to the `Edit` tab within the microservice and you will see the JavaScript code that runs when an HTTP GET request is made. Replace the GET function code with the following:

```javascript
function onGet(context) {
    return context.stores.density('doorway_hourly').count();
}

module.exports = onGet;

```

Select the `GET` button from the test panel on the right hand side to execute the GET function. You should see a result of `0`. This simply connect to the database and counts the records which is a good indication that the connection is successful. If this fails, check the `Log` tab for further information.


![Eventn - Test Store](/Docs/3_eventn-test-store.png?raw=true "Eventn - Test Store")



#### 6) Setup the Eventn Functions

Once you have successfully tested your store connectivity, we can add the function code. Within this repository you will see two files: `eventn.get.js` and `eventn.post.js`.

As per the file naming, copy the contents of the `eventn.get.js` file to the Event `GET` function and copy the contents of the `eventn.post.js` file to the Eventn `POST` function. Note: use the tabs above the code window to navigate between the `GET` and `POST` functions.

**GET Function**

The `eventn.get.js` is simply used to populate the `meta_space` table with details of the spaces such as name, description and capacity. The purpose of this table is to simply provide meta data for easier navigation around the data using a visualization tool such as Tableau. 

The data for this table is collected by making a request to the Density API `/spaces` resource. To run this, replace the `densityApiToken` value with your own Density API key.


```javascript
const densityApiToken = '*********************';
```

This function only needs to be run once, or each time you modify your spaces within Density (note you will need to truncate the table beforehand if you are re-running). You can execute the script by again pressing the `GET` button from the function test panel on the right. Once complete, you should see records within the `meta_space` table. For example:


![meta_space table](/Docs/4_meta-space-table.png "meta_space table")



#### 6) Create the Density Webhook

To get the data flowing between Density and Eventn, a Density Webhook must be created. In order to do this, you will need the public URL of the Eventn microservice along with the Eventn authentication token. These can be found on the `Manage` tab of the Eventn microservice: 

![Microservice Details](/Docs/5_eventn-microservice-details.png "Microservice Details")

Using these credentials you can call the Density API to create a new webhook. See https://docs.density.io/v2/#webhooks-create for details. Here is an example request using CURL:


```
curl -X POST \
-H "Content-Type: application/json" \
-H "Authorization: Bearer YOUR_DENSITY_API_TOKEN" \
-d '{
    "endpoint": "https://service.eventn.com/YOUR_MICROSERVICE_ADDRESS",
    "headers": {
        "Authorization": "Bearer YOUR_EVENTN_API_TOKEN"
    }
}' \
https://api.density.io/v2/webhooks/
```

Once created, based on real-time doorway events, you should see data flowing in to your Eventn functions (check the `Log` tab) as well as your MySQL database.


#### 7) Tableau Visualization
 
This repository also includes an example Tableau workbook that can be used to connect to the MySQl database and visualize the data. Of course any SQL or BI tool can be used..


![Example Tableau Dashboard](/Docs/6_density-tableau.png "Example Tableau Dashboard")
