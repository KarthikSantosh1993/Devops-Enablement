// Jenkinsfile for Salesforce Delta Deployment
// This version injects credentials using the top-level 'environment' block.

pipeline {
  agent { label 'salesforce-agent' } 
  environment {
    QA_JWT_KEY_FILE = credentials('2a9ccd87-eb8d-4a88-95b1-e70469f510bc')  // EC2 JWT key file for QA org
    QA_CONSUMER_KEY = credentials('3dd72e62-1327-42ce-bed2-452d2092ccf7')  // EC2 Consumer Key for QA org   
    QA_ORG_USERNAME = credentials('0d0f2b9c-87f5-42a1-ad7d-c402a975cf3d')  // EC2 QA org username 
    
    TARGET_ORG_ALIAS = 'qa-org' // Alias for the target org
    SOURCE_BRANCH = "origin/main" // Branch to compare for changes
    OUTPUT_DIR = "delta-package"   // Output directory for delta files
    }
  
  
    stages { // Start of stages
        stage('Checkout Source Code') {
            steps {
                // Clean the workspace before checkout
                cleanWs()

                // Checkout a specific branch ('main' in this case)
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']], // <-- Specify the branch here
                    userRemoteConfigs: [[url: 'https://github.com/KarthikSantosh1993/Devops-Enablement.git']]
                ])
                sh "echo git branch -a"
            }
        } //end of checkout stage
        
        stage('install sfdx-git-delta plugin') { // Check sf version and install sfdx-git-delta plugin if not present
            steps {
                sh 'sf --version'
                sh 'sfdx plugins --core |grep sfdx-git-delta || echo y |sfdx plugins:install sfdx-git-delta'
            }
        } // End of install sfdx-delta plugin if not installed stage

        stage('Authenticate qa org') {  // Authenticate to QA org using JWT
            steps {
                echo "${QA_JWT_KEY_FILE}"
                withCredentials([file(credentialsId: '2a9ccd87-eb8d-4a88-95b1-e70469f510bc', variable: 'QA_JWT_KEY_FILE')]) {
                    sh "sf org login jwt --client-id $QA_CONSUMER_KEY --username $QA_ORG_USERNAME --jwt-key-file \"${QA_JWT_KEY_FILE}\" --alias ${TARGET_ORG_ALIAS} --set-default"
                }
            }
        } // End of Authenticate to Orgs stage
        // STAGE: Generate Delta Package
        stage('Generate Delta Package') {
            steps {
                
                sh "mkdir -p ${OUTPUT_DIR}"
                echo "Generating delta package against branch '$SOURCE_BRANCH'..."
                sh "sfdx sgd source delta --to HEAD --from $SOURCE_BRANCH --output-dir ${OUTPUT_DIR}/"
                
                sh "cat ${OUTPUT_DIR}/package/package.xml"
                script {
                    def directoryExists = sh(script: 'test -d delta-package/force-app', returnStatus: true) == 0
                    // dirExists is a built-in Jenkins step to check for a directory.
                    if (directoryExists) {
                        echo "Changes found. Proceeding with validation and deployment."
                        // Set an environment variable to use in the 'when' block of later stages.
                        env.CHANGES_FOUND = 'true'

                        echo "The following components were changed:"
                        sh "cat ${OUTPUT_DIR}/package/package.xml"
                    } 
                    else {
                        echo "No changes found in 'force-app' to deploy."
                        env.CHANGES_FOUND = 'false'
                    }
                }   
            }
        } // End of Generate Delta Package stage

        
        // STAGE: Validate Changes
        stage('Validate Changes') {
            when {
                expression { env.CHANGES_FOUND == 'true' }
            }
            steps {
                echo "Validating deployment against org: $TARGET_ORG_ALIAS"
                sh """
                    sfdx project:deploy:validate \\
                      --target-org $TARGET_ORG_ALIAS \\
                      --source-dir delta-package/force-app \\
                      --test-level RunLocalTests \\
                      --wait 20
                """
            }
        }

        // STAGE: Deploy to Target Org
        stage('Deploy to Target Org') {
            when {
                expression { env.CHANGES_FOUND == 'true' }
            }
            steps {
                echo "Deploying changes to org: $TARGET_ORG_ALIAS"
                sh """
                    sfdx project:deploy:start \\
                      --target-org $TARGET_ORG_ALIAS \\
                      --source-dir delta-package/force-app \\
                      --test-level RunLocalTests \\
                      --wait 20
                """
            }
        }

        stage('install sfdx-scanner plugin if not installed') { // install sfdx-scanner if not present
            steps {
                sh 'sf --version'
                sh 'sfdx plugins --core |grep sfdx-scanner || echo y |sf plugins install @salesforce/sfdx-scanner'
            }
        } // End of install sfdx-scanner plugin if not installed stage
        

        stage('🔬 Static Code Analysis') {
            steps {
                script {
                    // Ensure the output directory exists
                    sh 'mkdir -p scan-results'

                    // Run the SF scanner and output the results as a JUnit XML file.
                    // The command will fail if any rule with severity 1, 2, or 3 is violated.
                    sh """
                        sf scanner run --target "./force-app" \
                                    --category "Apex Security,Best Practices,Performance,Error Prone" \
                                    --format junit \
                                    --outfile "scan-results/apex-scan-results.xml" \
                                    --engine pmd \
                                    --severity-threshold 3
                    """
                }
            }
        } // End of Static Code Analysis stage
    
    } // End of stages

    // 4. Post-build Actions
    post {
        always {
            echo 'Archiving PMD results'
            // Publish the JUnit XML results from the static code analysis.
            junit 'scan-results/apex-scan-results.xml', allowEmptyResults: true

            echo 'Pipeline finished. Logging out from Salesforce org...'
            // The '|| true' ensures this step doesn't fail the build if authorization failed.
            sh "sfdx auth:logout --target-org $TARGET_ORG_ALIAS --no-prompt || true"
            cleanWs()
        }
    }
}