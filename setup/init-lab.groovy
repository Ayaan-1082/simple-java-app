import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration
import hudson.security.HudsonPrivateSecurityRealm
import hudson.security.FullControlOnceLoggedInAuthorizationStrategy
import hudson.slaves.EnvironmentVariablesNodeProperty
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition

def j = Jenkins.get()
def root = new File(System.getenv('LAB_ROOT'))
def home = new File(System.getenv('JENKINS_HOME'))
def password = new File(home, 'lab-password.txt').text.trim()
if (!(j.securityRealm instanceof HudsonPrivateSecurityRealm)) {
    def realm = new HudsonPrivateSecurityRealm(false)
    realm.createAccount('labadmin', password)
    j.securityRealm = realm
}
def authorization = new FullControlOnceLoggedInAuthorizationStrategy()
authorization.setAllowAnonymousRead(false)
j.authorizationStrategy = authorization
j.numExecutors = 2
j.setLabelString('windows-lab')
j.systemMessage = 'Kubernetes practical lab: 15 independent sets. See START-HERE.md for verified results.'
JenkinsLocationConfiguration.get().setUrl('http://localhost:8081/')
def envProperty = j.globalNodeProperties.get(EnvironmentVariablesNodeProperty)
if (envProperty == null) {
    envProperty = new EnvironmentVariablesNodeProperty()
    j.globalNodeProperties.add(envProperty)
}
envProperty.envVars.put('KUBECONFIG', new File(home, 'kubeconfig').absolutePath)
envProperty.envVars.put('LAB_ROOT', root.absolutePath)
envProperty.envVars.put('PATH', System.getenv('PATH'))
def preparation = '''
        stage('Load local lab files') {
            steps {
                powershell ''' + "'''" + '''
$ErrorActionPreference = 'Stop'
Get-ChildItem -LiteralPath $env:LAB_ROOT -Force |
    Where-Object { $_.Name -notin @('.git', 'evidence', 'node_modules', '.runtime') } |
    Copy-Item -Destination . -Recurse -Force
''' + "'''" + '''
            }
        }
'''
(1..15).each { number ->
    def id = String.format('%02d', number)
    def pipelineFile = new File(root, "sets/set-${id}/Jenkinsfile")
    if (pipelineFile.exists()) {
        def name = "K8s-Set-${id}"
        def job = j.getItem(name)
        if (job == null) job = j.createProject(WorkflowJob, name)
        def source = pipelineFile.getText('UTF-8')
        source = source.replaceFirst(/stages\s*\{/) { match -> match + preparation }
        job.setDefinition(new CpsFlowDefinition(source, true))
        job.setDescription("Kubernetes practical set ${number}. Files: sets/set-${id}. Local rehearsal loads files from LAB_ROOT. See the README for GitHub configuration.")
        job.save()
    }
}
j.save()
println('Kubernetes practice jobs configured on http://localhost:8081/')
