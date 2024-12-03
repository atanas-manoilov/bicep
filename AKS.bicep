@description('The ID of the subnet for the AKS node pool.')
param vnetSubnetID string

@description('The location of the AKS cluster.')
param location string = resourceGroup().location

@description('The name of the AKS cluster.')
param clusterName string = 'aks-cluster'

@description('The DNS prefix for the AKS cluster.')
param dnsPrefix string = 'aks-dns'

@description('The number of agent nodes in the node pool.')
param agentCount int = 2

@description('The VM size of the agent nodes.')
param agentVMSize string = 'Standard_D2_v4'

@description('The version of Kubernetes to deploy. Leave empty for the default version.')
param kubernetesVersion string = ''

@description('Naskos user ')
param amanoilov_user string = 'nasko'

@description('SSH public key for cluster admin access.')
param sshPublicKey string = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCTTO5ZFKWfkHzOYBo2jqCeuZfzEuxF34w+ATdi9qy9v4qYfpKyvlgQuoaxzdZCQ9p8Bnz6nBNi3yXaTvaeQvgJ4D6HFhboNQS9V4f8btiPiM+yDwBFBWIqSmUPN5LwYH8FDEanagz3h96ByR1q4PPET4guOMXlLAHggSLRVORNn1IstNEFKK92gN72Xs02S7c/4tYovMSZ7u3NJ9bvFSWrA4y1CdN/u2QBcL/Y1v0CitIiJLAID5TycpxU6cFHdg//s2iO0t1GN8uStI6HBGfsnj/FtBlpxHcSWFzGD+bt++pNCnJ6xkjR6xnEfJUkRB3m7FfhDWx9FFnvQZ72OjV0MppoafPU4NFdRVePqLecMaJTbRHEJ1pz9pRocueehHP2YjvrcyfE0nBVpec7/uJNBYI7U0HjH6Vaj4j9KW4zomEfl+l3l/mYiQm1GaIj4gN4OI+OmTt96FX0qQ83UU1H7N/6OdmORWidx9gZCxyAFsECKDM+jfzSofQhGihddN8uijZh5Z/mb+hEQ55Frl4p5vhjMKEygW0DEja4vsacJmHcOXw4Dy1UQAbwUIo66d23CMJLxh42/OChJS6jLOlP1Y1JsYObf06/UjbwgJazet+++rjAk/ynO2Xl6Gyz5GWt/MxaXWJCJVZ2z0ugQbH1VVB+rZ/LerOICkKtnr9WQQ== nasko@D7440'

resource cluster 'Microsoft.ContainerService/managedClusters@2023-11-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: vnetSubnetID
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: amanoilov_user
      ssh: {
        publicKeys: [
          {
            keyData: sshPublicKey
          }
        ]
      }
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      serviceCidr: '192.168.0.0/24'
      dnsServiceIP: '192.168.0.10'
      podCidr: '172.16.0.0/16'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
    }
  }
}

output aksClusterName string = clusterName
output aksClusterResourceGroup string = resourceGroup().name
output kubeletUAMIClientId string = reference(cluster.id, '2023-07-01').identityProfile.kubeletidentity.clientId
output kubeletUAMIObjectId string = reference(cluster.id, '2023-07-01').identityProfile.kubeletidentity.objectId
output kubeletUAMIResourceId string = reference(cluster.id, '2023-07-01').identityProfile.kubeletidentity.resourceId

