Import-Module "$PSScriptRoot/Streams.psm1"
Import-Module "$PSScriptRoot/Invoke-Executable.psm1"
Import-Module "$PSScriptRoot/Initialize-TestNamespace.psm1"

Describe Get-KubePod {

    BeforeAll { Initialize-TestNamespace }

    It 'Should return the pods that exist in a namespace' {
        $pods = Get-KubePod -Namespace pskubectltest
        $pods.Count | Should -Be 2
        $pods | ForEach-Object {
            $_ | Should -BeOfType KubeClient.Models.PodV1
            $_.Name | Should -BeLike 'hello-world-*'
            $_.Namespace | Should -Be 'pskubectltest'
            $_.Status.Phase | Should -Be 'Running'
        }
    }
}


Describe Get-KubeDeployment {

    BeforeAll { Initialize-TestNamespace }

    It 'Should return the deployments that exist in a namespace' {
        $deploy = Get-KubeDeployment -Namespace pskubectltest
        $deploy.Count | Should -Be 1
        $deploy | Should -BeOfType KubeClient.Models.DeploymentV1
        $deploy.Name | Should -Be 'hello-world'
        $deploy.Namespace | Should -Be 'pskubectltest'
        $deploy.Desired | Should -Be 2
        $deploy.Current | Should -Be 2
    }
}

Describe Get-KubeNamespace {

    BeforeAll { Initialize-TestNamespace }

    It 'Should return the deployments that exist in a namespace' {
        $namespaces = Get-KubeNamespace
        $namespaces | Where-Object { $_.Name -eq 'pskubectltest' } | Should -Not -BeNullOrEmpty
        $namespaces | Should -BeOfType KubeClient.Models.NamespaceV1
    }
}

Describe Update-KubeResource {

    BeforeAll { Initialize-TestNamespace }

    It 'Should update the resource from pipeline input' {
        $before = (Invoke-Executable { kubectl get deploy -n pskubectltest -o json } | ConvertFrom-Json).Items
        $modified = [pscustomobject]@{
            Kind = 'Deployment'
            ApiVersion = 'v1'
            Metadata = [pscustomobject]@{
                Name = 'hello-world'
                Namespace = 'pskubectltest'
            }
            Spec = [pscustomobject]@{
                Replicas = 3 # increase replicas by 1
            }
        }
        $result = $modified | Update-KubeResource
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType KubeClient.Models.DeploymentV1
        $result.Spec.Replicas | Should -Be 3
        $after = (Invoke-Executable { kubectl get deploy -n pskubectltest -o json } | ConvertFrom-Json).Items
        $after.Spec.Replicas | Should -Be 3
        $after.Metadata.Annotations.'kubectl.kubernetes.io/last-applied-configuration' | Should -Not -Be $before.Metadata.Annotations.'kubectl.kubernetes.io/last-applied-configuration'
    }
}

Describe Compare-KubeResource {

    BeforeAll { Initialize-TestNamespace }

    It 'Should update the resource from pipeline input' {
        $before = (Invoke-Executable { kubectl get deploy -n pskubectltest -o json } | ConvertFrom-Json).Items
        $modified = [pscustomobject]@{
            Kind = 'Deployment'
            ApiVersion = 'v1'
            Metadata = [pscustomobject]@{
                Name = 'hello-world'
                Namespace = 'pskubectltest'
            }
            Spec = [pscustomobject]@{
                Replicas = 3 # increase replicas by 1
            }
        }
        $result = $modified | Update-KubeResource
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType KubeClient.Models.DeploymentV1
        $result.Spec.Replicas | Should -Be 3
        $after = (Invoke-Executable { kubectl get deploy -n pskubectltest -o json } | ConvertFrom-Json).Items
        $after.Spec.Replicas | Should -Be 3
        $after.Metadata.Annotations.'kubectl.kubernetes.io/last-applied-configuration' | Should -Not -Be $before.Metadata.Annotations.'kubectl.kubernetes.io/last-applied-configuration'
    }
}

Describe Get-KubeConfig {

    It 'Should return kube configuration' {
        $config = Get-KubeConfig
        $config.CurrentContextName | Should -Not -BeNullOrEmpty
        $config.CurrentContext | Should -Not -BeNullOrEmpty
        $config.Clusters | Should -Not -BeNullOrEmpty
        $config.Contexts | Should -Not -BeNullOrEmpty
    }
}