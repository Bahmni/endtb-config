Specification Heading
=====================
Created by dharmens on 7/5/16

This is an executable specification file which follows markdown syntax.
Every heading in this file denotes a scenario. Every bulleted point denotes a step.


Create Patient and Enrollment of Patient to Program
---------------------------------------------------

* On the login page
  * Login with username "superman" and password "Admin123"
  * Click on registration app
  * Click on create new patient link
  * Create the following patient
      |EMR_ID_PREFIX|FirstName|Last Name|Gender|Date Of Birth|Address1|nationalIdentificationNumber|
      |GAN|Program|Test|Male|20/01/2011|Bilaspur|13898|
* Navigate to dashboard
* Click on programs app
* Select the existing patient from patient listing page under tab "All"
* Register the patient to following program
    |TB Register|Date Of Registration|Registration Number|Registration Facility|
    |Basic management unit TB register|01/01/2015|ABC|Facility1, City1, Country1|
* Ensure that the patient is registered to mentioned program


Editing of Program Attributes
-----------------------------

* Navigate to dashboard
* Click on programs app
* Select the existing patient from patient listing page under tab "All"
* Edit attribute to registration "DEF" and facility "Facility1, City1, Country1"
* Ensure that the patient is registered to mentioned program
