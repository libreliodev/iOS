Customization
==

The customization is done by adding a new target. In order to do so:

1- create a directory with all specific resources for the app. This should include a file called application.plist, and specific pngs  listed at http://www.librelio.com/how-it-works/customization.

2- create a new target by duplicating the "empty" target. The empty target contains all common resources and classes required.

3- add the application resources directory to the new target

<img alt="build" src="http://www.librelio.com/images/readme/readme0.png" width="800">

4- in the target build settings, under Packaging, change info.plist File, and change Product Name

<img alt="build" src="http://www.librelio.com/images/readme/readme1.png" width="800">

5- in the target summary, enter the Bundle Identifier for your app 

<img alt="build" src="http://www.librelio.com/images/readme/readme2.png" width="800">

