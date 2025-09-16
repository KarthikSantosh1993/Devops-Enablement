pipeline{  
  agent any
  environment {
    DEV_JWT_KEY_FILE = credentials('0102f6b5-8e52-4b55-99a4-82de2080b194') // JWT key file for Dev org
    QA_JWT_KEY_FILE = credentials('cc1312b7-42ed-41df-b062-a4323f5fe1d7')  // JWT key file for QA org

    DEV_CONSUMER_KEY = credentials('2f9d9d34-0cb5-4458-a1da-84f85cd7bd1e') // Connected App Consumer Key for Dev org
    QA_CONSUMER_KEY = credentials('b09e5fc2-513f-4eb6-98aa-d4bab5e51eab')  // Connected App Consumer Key for QA org   

    DEV_ORG_USERNAME = credentials('c21428b5-924a-4a61-b390-4fe4fda97329') // Dev org username
    QA_ORG_USERNAME = credentials('b8ed0e2b-56cc-4a2a-9f27-301862a30d87')  // QA org username 


    SOURCE_BRANCH = "main" // Branch to compare for changes
    OUTPUT_DIR = "delta"   // Output directory for delta files
    sf = '/usr/local/bin/sf'
} // End of environment
  stages {
    
    stage('Initialize') {
         steps {
                sh 'export PATH=/usr/local/bin/sf'
                sh 'echo "Salesforce CLI Version:"'
                sh '$sf --version'
               
                sh 'echo "================================================="'

                sh 'echo "Starting Salesforce Deployment Pipeline"' 
                sh 'echo "Checking if sfdx-git-delta plugin is installed..."'
                sh '$sf plugins --core | grep sfdx-git-delta || $sf plugins:install sfdx-git-delta'  
                } 
            } //End of Initialize stage

  //   stage('Authenticate to Orgs') {
  //        steps {
  //               sh "sfdx force:auth:jwt:grant --clientid $DEV_CONSUMER_KEY --jwtkeyfile $DEV_JWT_KEY_FILE --username $DEV_ORG_USERNAME --setdefaultusername --setalias dev-org"
  //               sh "sfdx force:auth:jwt:grant --clientid $QA_CONSUMER_KEY --jwtkeyfile $QA_JWT_KEY_FILE --username $QA_ORG_USERNAME --setalias qa-org"
  //               }
  //        }
  // }
  //   stage('Generate Delta') {
  //        steps {
  //               sh "sfdx gdt:source:delta --to $SOURCE_BRANCH --output $OUTPUT_DIR --json > delta.json"
  //               sh 'cat delta.json'
  //               }
  //        }
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