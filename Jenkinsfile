node {
    stage('Clone') { // for display purposes
        // Clone the configurations repository
        cleanWs()
        git 'https://github.com/BigDevopsTemy/terraform.git'   
    }
    stage('Download') {
    // Download Terraform for Linux
        sh label: '', script: 'curl -LO https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip \
            && unzip terraform_0.12.29_linux_amd64.zip'

        // Make the binary executable
        sh label: '', script: 'chmod +x terraform'

        // Optional: Move it to a directory in your PATH
        sh label: '', script: 'sudo mv terraform /usr/local/bin/'

        // Clean up the downloaded zip file
        sh label: '', script: 'rm terraform_0.12.29_linux_amd64.zip'
    }

    stage('Backend-Init') {
        // Initialize the Terraform configuration
        dir('.') {
            sh script: '../../terraform init -input=false'
        }
        
    }
    stage('Backend-Plan') {
        // Create Terraform plan for backend resources
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
            dir('.') {
                sh script: '../../terraform plan \
                        -out backend.tfplan \
                        -var="aws_access_key=$aws_access_key" \
                        -var="aws_secret_key=$aws_secret_key"'
            }
        }
    }
    stage('Backend-Apply') {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('03_01_remotestate/remote_resources') {
                                sh script: '../../terraform apply backend.tfplan'
                            }
        }
    }
    stage('Config-Init') {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('.') {
                                sh script: '../terraform init \
                                            -backend-config="bucket=red30-tfstate" \
                                            -backend-config="key=red30/ecommerceapp/app.state" \
                                            -backend-config="region=us-east-2" \
                                            -backend-config="dynamodb_table=red30-tfstatelock" \
                                            -backend-config="access_key=$aws_access_key" \
                                            -backend-config="secret_key=$aws_secret_key"'
                            }
                        }
    }
    stage('Config-Plan') {
        // Generate Terraform plan
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('03_01_remotestate') {
                                sh script: '../terraform plan \
                                            -out s1.tfplan \
                                            -var="aws_access_key=$aws_access_key" \
                                            -var="aws_secret_key=$aws_secret_key"'
                            }
        }
    }
    stage('Config-Apply') {
        // Apply the configuration
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('03_01_remotestate') {
                                sh script: '../terraform apply s1.tfplan'
                            }
        }
    }
    stage('Destroy'){
        input 'Destroy?'
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
            dir('03_01_remotestate') {
                sh script: '../terraform destroy \
                        -auto-approve \
                        -var="aws_access_key=$aws_access_key" \
                        -var="aws_secret_key=$aws_secret_key"'
            }
            dir('03_01_remotestate/remote_resources') {
                sh script: '../../terraform destroy \
                        -auto-approve \
                        -var="aws_access_key=$aws_access_key" \
                        -var="aws_secret_key=$aws_secret_key"'
            }
        }
    }
}