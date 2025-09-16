pipeline {
  agent any
  environment {
    DEV_JWT_KEY_FILE = credentials('0102f6b5-8e52-4b55-99a4-82de2080b194') // JWT key file for Dev org
    QA_JWT_KEY_FILE = credentials('cc1312b7-42ed-41df-b062-a4323f5fe1d7')  // JWT key file for QA org

    DEV_CONSUMER_KEY = credentials('5f9aa70d-d059-4692-89e6-6c2e3e0d9d5f') // Connected App Consumer Key for Dev org
    QA_CONSUMER_KEY = credentials('b09e5fc2-513f-4eb6-98aa-d4bab5e51eab')  // Connected App Consumer Key for QA org   

    DEV_ORG_USERNAME = credentials('c21428b5-924a-4a61-b390-4fe4fda97329') // Dev org username
    QA_ORG_USERNAME = credentials('b8ed0e2b-56cc-4a2a-9f27-301862a30d87')  // QA org username 


    SOURCE_BRANCH = "main" // Branch to compare for changes

    OUTPUT_DIR = "delta"   // Output directory for delta files

    sf = '/usr/local/bin/sf'
    sfdx = '/usr/local/bin/sfdx'
  }
  stages {
    stage('check sf version') {
        steps {
              sh '$sf --version'
              sh '$sfdx plugins --core |grep sfdx-git-delta || $sfdx plugins:install sfdx-git-delta' 
            }
        }
    stage('Authenticate to dev and qa orgs') {
         steps {
              // Create output directory if it doesn't exist
              
              //dev org authorization comand with alias flag
              sh "$sfdx force:auth:jwt:grant --client-id $DEV_CONSUMER_KEY --jwt-key-file $DEV_JWT_KEY_FILE  --username $DEV_ORG_USERNAME --alias dev-org"

              //qa org authorization command with alias flag
              sh "$sfdx force:auth:jwt:grant --client-id $QA_CONSUMER_KEY --jwt-key-file $QA_JWT_KEY_FILE --username $QA_ORG_USERNAME --alias qa-org"  
       }    
     } // End of Authenticate to Orgs stage
  

    stage('Generate Delta Files') {
        steps {
           script {
           
            sh "git fetch --unshallow || true" // Ensure full history is available for comparison
            
            sh "mkdir -p ${OUTPUT_DIR}" // Ensure the output directory exists.

            def deltaOutput = sh(
                script: "$sfdx sgd:source:delta --from $SOURCE_BRANCH --to HEAD --output-dir $OUTPUT_DIR",
                returnStdout: true
            ).trim()

            // Check if any changes were detected by parsing the JSON output.
            if (deltaOutput == '{}') {
                echo "No changes were detected between main and HEAD. No delta files were generated."
            } else {
                echo "Delta generation completed."
                echo "Listing generated package files:"
                sh "ls -R ${OUTPUT_DIR}"
            }
          }
        }
    }
  //   stage('Deploy to QA') {
  //        steps {
  //               sh "sfdx force:source:deploy -p $OUTPUT_DIR --targetusername qa-org --wait 10 --testlevel RunLocalTests"
  //               }
  //        }
  //   stage('Run Post-Deployment Tests') {
  //        steps {
  //               sh "sfdx force:apex:test:run --targetusername qa-org --resultformat human --wait 10"
  //               }
  //        }         
    } // End of stages


} // End of pipeline