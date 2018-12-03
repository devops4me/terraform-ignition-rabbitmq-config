
pipeline
{
    agent { dockerfile true }

    stages
    {
        stage('terraform init')
        {
            steps
            {
		sh 'terraform init integration.test.dir'
            }
        }
        stage('terraform apply')
        {
            steps
            {
		sh 'terraform apply -auto-approve integration.test.dir'
            }
        }
        stage('terraform destroy')
        {
            steps
            {
		sh 'terraform destroy -auto-approve integration.test.dir'
            }
        }
    }
}
