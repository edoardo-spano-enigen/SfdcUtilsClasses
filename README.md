# SfdcUtilsClasses
Some useful utility classes for Salesforce.com projects.

## PACKAGE'S COMPONENTS
- package.xml
- A utility class for constants (K)
- A utility class for Apex triggers (T) and related test class
- A utility class for common operations (U) and related test class

## DEPLOY TO SALESFORCE
To install this package please follow the following steps:
1. Clone this repository.
2. Create a .zip file with the contents of the repository. NOTE: verify that all components (package.xml file and folders) are in the root of the .zip file, otherwise the deploy will fail.
3. Log in to destination Salesforce environment.
4. Open and log in to Workbench.
5. Navigate to Migration > Deploy.
6. Select the .zip file created at step 2.
7. Set this flags to true:
	* Check Only
	* Rollback On Error
	* Single Package
8. Click on Next.
9. Click on Deploy.
10. Await until the validation is finished and check that the status is Succeeded.
11. Repeat the steps 4-8, without set Check Only to true.

## POST DEPLOY ACTIVITIES
After the package is deployed, plan to perform the following actions:
1. Review all deployed components.
2. Adapt the deployed components to your needs. Be careful to replace all the mock labels, names, descriptions, etc. with relevant information, with respect on the project guidelines.
3. If some components are not necessary for your business, plan to remove them. Leave unnecessary and unused components spread around is not a best practice at all!
4. Check that all test classes run correctly inside your configuration.
