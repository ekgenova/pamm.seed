PAMM - SEED
-----------

PAMM-SEED is a template for building Web Applications using the PAMM stack:

-   [Play](https://www.playframework.com/) for server side web pages and services

-   [AngularJS](https://angularjs.org/) for client side rich user interfaces

-   [MariaDb](https://mariadb.org/) for relational data

-   [MongoDb](https://www.mongodb.org/community) for document based non-relational data

Index
-----

**1. Architecture**

**2. Play Component**

    1.  Http Layer

    2.  Business Service Layer

    3.  Data Persistence Layer

**3. Angular Component**

**4. Testing**

    1.  Application End to End Testing

    2.  Angular Client Unit Testing

    3.  Play Unit Testing

**5. Running the application**

1. Architecture
---------------

The following diagram shows the high level reference architecture for the application: ![](./docs/img/pamm.gif)

2. Play Component
-----------------

The Play component of the PAMM seed consists of the following component layers:

### 2.1 Http Layer ###

The Http layer exposes the applications RESTful API to clients, facilitated by the [Play framework routing mechanism](https://www.playframework.com/documentation/2.4.3/JavaRouting). Each resource endpoint exposes a RESTful API for a single application resource.

The Resource Endpoints responsibility is to accept requests for a resource and delegate the processing of that request to a Business Service Layer component. The Transactional boundary for the processing of a request is defined on the Action methods of the Resource Endpoints.![](./docs/img/play.gif)

### 2.2 Business Service Layer ###

The Business Service layer services provide a [façade](https://en.wikipedia.org/wiki/Facade_pattern) style interface to a number of underlying service operations. Each service is an aggregation of service operations, with each service operation providing business logic to maintain application resources.

Each service operation should inherit from the ServiceOperation superclass, with any application "cross cutting" behaviour (e.g. application level authentication and authorization, audit, error handling) being managed by the ServiceOperation superclass. Comments have been included in this class as a placeholder for this logic to be included if required.

### 2.3 Data Persistence Layer ###

The Data Persistence layer provides the application persistence mechanism and its data model. This seed uses JPA with a Hibernate implementation to persist data to an in-memory H2 database. 

#### 2.3.1 Configuration ####

This requires the following configuration (already set up in the seed).

a) conf/application.conf - Defines configuration for the Datasource to access the H2 database. Specifies the jdbc url, the jndi name for the Datasource, the H2 database driver.

The default persistence unit for the application is also defined in the application.conf file by setting the jpa.default property. When play.db.jpa.JPA.em() is invoked with no arguments, it will return an Entity manager for this default persistence unit. 

b) conf/META-INF/persistence.xml - Defines the persistence unit for the application, specifying Hibernate as the persistence provider and referencing the H2 database datasource.

c) build.sbt - include the dependencies for javaJpa and hibernate.

#### 2.3.2 High Level Class Structure ####
![](./docs/img/persistence.gif)

*GenericReadOnlyDao*: Base class for all application Data access objects, providing methods to find, list and search for entities. An EntityManager instance is made available through the EntityManagerProvider factory class. This is obtained from the play.db.jpa.JPA.em() static method returning an entity manager instance for the currently running thread.

*GenericDao*: Provides generic methods to create, update and delete entities.

*EntityManagerProvider*: Factory class to encapsulate the play.db.jpa.JPA static method to return the EntityManager instance for the currently running thread.

Any entity specific queries should be placed in the Dao associated with that entity. E.g. If the ProjectEntity requires a database query not included in the Generic Dao classes, then a method for that database query should be added to the ProjectDao class.


3. Angular Component
--------------------

*In Development*

4. Testing
----------


### 4.1 Application End To End Testing ###

For the Application End To End Testing, we are using the Protractor end to end testing framework along with the Cucumber BDD tool. 

Protractor (and our end to end test scripts) run on a node.js server and communicate with a Selenium server through Selenium Webdriver API bindings. This link provides an overview of the [Protractor testing components](https://angular.github.io/protractor/#/infrastructure) and how they collaborate to run the end to end tests:


#### 4.1.1 Prerequisites ####

Modules required to run the Protractor end to end tests are specified in the [Protractor readMe file](svc/test/cucumber/README_protractor)

#### 4.1.2 Test Configuration ####

The following files have been configured to run the Protractor end to end tests for the seed:

**[Protractor conf.js file](svc/test/cucumber/conf.js)**

The following link provides a comprehensive list of properties that can be set for your [Protractor configuration](https://github.com/angular/protractor/blob/master/docs/referenceConf.js), and descriptions of how to use these properties.


**[package.json](./package.json)**

The following link provides a comprehensive list of properties that can be set for your [npm package.json configuration](https://docs.npmjs.com/files/package.json), and descriptions of how to use these properties.


#### 4.1.3 Test structure ####

Each feature being tested will have the following fileset located under the following base folder

		svc/test/cucumber/features/


- A Gherkin feature file defining the Feature to be tested and the test scenarios for the feature. See the [manage-project.feature](svc/test/cucumber/features/manage-project/manage-project.feature) for an example feature file.


- A cucumber script implementing the steps defined in the Gherkin feature file, to test the scenarios in the Gherkin feature file. See the [manage-project step definition](svc/test/cucumber/features/manage-project/stepDefinitions.js) for an example cucumber step definition script.
 

- Page Object script(s), encapsulating the user interface actions required by the cucumber scripts in order to implement the scenarios defined in the Gherkin feature file.  See the [manage-project page model](svc/test/cucumber/features/page-models/manage-project.page.js) for an example page model.


Scenarios that require data setup, should make use of the testsetup child project included in the seed. This is a Play application exposing a RESTful API for the execution of SQL scripts. To invoke a SQL script through the testsetup application, cucumber scripts should invoke the executeScript(scriptNumber) function of the following script. 

		svc/test/cucumber/features/util/setup-service-caller.js

See the call to setup.executeScript(1) in the  [manage-project step definition](svc/test/cucumber/features/manage-project/stepDefinitions.js) for an example.  

The SQL scripts to set up test data should be placed in the following directory of the testsetup child project

		testsetup/conf/sql-scripts/ 

and referenced in the [config.properties](./testsetup/conf/config.properties) file.


#### 4.1.4 Test Execution ####

**Running from command line**

To run the Protractor tests open a command window at the PAMM seed root folder.

Enter the following command

     npm run protractor-test

This will invoke the protractor-test "event" in the [package.json](./package.json) file, which runs the command "./node_modules/.bin/protractor svc/test/cucumber/conf.js"

This will output the Gherkin style scenario description for each scenario run, and display which tests have passed or failed. 

**Running as part of project build**

The [build.sbt](build.sbt) file has been configured to invoke the Protractor tests to execute  as part of the sbt endToEndTest task.

The [EndToEndTestTask.scala](project/EndToEndTestTestTask.scala) file contains the definition for this task. The task will start up a selenium server, start an H2 database, run the svc project, run the testsetup project and finally run the protractor tests.

To run the Protractor tests through the build task, open a command window at the PAMM seed root folder and run the following command

    activator svc/endToEndTest

This will invoke the Play unit tests as well as the Angular client unit tests.


### 4.2 Angular Client Unit Testing ###

For the unit testing of the Angular client components, Jasmine test framework libraries are used to create the test functions, with these tests being run by the karma test runner framework.

#### 4.2.1 Prerequisites ####

Modules that are required to run the jasmine unit tests with the karma test runner framework are specified in the [Karma readMe file](svc/test/unit/README_karma).


#### 4.2.2 Test Configuration ####

The following files have been configured to invoke the karma test runner to execute the jasmine unit tests:

**[karma.conf.js:](svc/test/unit/karma.conf.js)**

The following link provides a comprehensive list of properties that can be set for your [Karma configuration](http://karma-runner.github.io/0.13/config/configuration-file.html), and descriptions of how to use these properties.


**[package.json](./package.json)**

The following link provides a comprehensive list of properties that can be set for your [npm package.json configuration](https://docs.npmjs.com/files/package.json), and descriptions of how to use these properties.


#### 4.2.3 Test structure ####

For unit testing of our Angular javascript components, the following convention has been followed.

For each javascript component that we unit test within the folder

		svc/public/webapp

a corresponding jasmine unit test component has been created in an identically named folder hierarchy within the folder

		svc/test/unit 

e.g. in order to test the component

		svc/public/webapp/feature/login/login-controller.js 

we would create the following jasmine test script 

		svc/test/unit/feature/login/login-controller.spec.js 

and html file

		svc/test/unit/feature/login/login-controller.test.html 


Each test has an html file defining the dependencies required to run the individual tests and a javascript file containing the jasmine unit test scripts to be executed.

See [login-controller.test.html](svc/test/unit/feature/login/login-controller.test.html) for an example of an html file defining the test dependencies, and [login-controller.spec.js](svc/test/unit/feature/login/login-controller.spec.js) for example jasmine test scripts.


#### 4.2.4 Test Execution ####


**Running from command line**

To run the jasmine tests with the karma test runner, open a command window at the PAMM seed root folder.

Enter the following command

     npm run jasmine-test

This will invoke the test "event" in the [package.json](./package.json) file, which runs the command "./node_modules/.bin/karma start svc/test/unit/karma.conf.js"

Any unsuccessful tests will be displayed on the command window, with details of the test that failed and the name of the jasmine file. 

**Running as part of project build**

The [build.sbt](build.sbt) file has been configured to invoke the karma test runner to execute the jasmine unit tests as part of the sbt test task.

The [ClientTestTask.scala](project/ClientTestTask.scala) file contains the definition for this client test task

To run the karma tests open a command window at the project root and enter the following command

    activator svc/test

This will invoke the Play unit tests as well as the Angular client unit tests.


### 4.3 Play Unit Testing ###

The PAMM seed folder structure adheres to the Play application convention, so in order for unit tests in the Play application to be invoked as part of the "sbt test" task, simply follow the instructions as detailed on the [Play Framework Testing page](https://www.playframework.com/documentation/2.4.3/JavaTest). 


5. Running the Application
----------

Open a command window at the project root folder and enter the following command

    activator svc/run

Once the "Server started" message is displayed in the command window, access the following URL in your browser

    http://localhost:9000

The PAMM login page should be presented. The seed has no authentication configured for this initial draft version, so by entering any username and password, the PAMM dashboard should be displayed. The angular client is integrated with the Play backend and any actions on the Angular client will be routed to the Play backend. 

**Note**: Projects added via the "Add New Project" feature of the PAMM application will be stored in an embedded in-memory H2 database. This initial version of the seed has no permanent persistence configured and any data stored in the H2 database will be lost when activator is stopped by entering the following command at the [svc] $ prompt

    exit




