// declare variables
param vwanName string = 'vwan-name'
param vwanHubName string = 'vwan-hub-name'
param location string = 'centralus'


// reference existing vwan hub
resource vhub 'Microsoft.Network/virtualHubs@2022-07-01' existing =  {
  name: vwanHubName
}

//create vpn gateway
resource vpnGateway 'Microsoft.Network/vpnGateways@2022-05-01' = {
  name: 'vpngw-test'
  location: location
  properties: {
    vpnGatewayScaleUnit: 1
    virtualHub: {
      id: vhub.id
    }
    bgpSettings: {
      asn: 65515
    }
  }
} 


