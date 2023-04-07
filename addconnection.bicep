// declare variables
param vwanName string = 'vwan-name'
param location string = 'centralus'
param enableBGP bool = true
param vpnSiteName string = 'sitename'
param vpnsiteAddressPrefixes array = ['10.x.x.x/x','10.x.x.x/x']
param vpnsiteASN int = 64600
param link1bgpPeeringAddress string = 'x.x.x.x'
param link1vpnsiteIPAddress string = 'x.x.x.x'
param link2bgpPeeringAddress string = 'x.x.x.x'
param link2vpnsiteIPAddress string = 'x.x.x.x'
param gatewayName string = 'vpngw-name'

@secure()
param link1sharedkey string
@secure()
param link2sharedkey string

//reference existing vwan
resource vwan 'Microsoft.Network/virtualWans@2022-07-01' existing =  {
  name: vwanName
}

// reference existing vwan hub
resource gateway 'Microsoft.Network/vpnGateways@2022-07-01' existing = {
  name: gatewayName
}
// create vpnsite
resource vpnSite 'Microsoft.Network/vpnSites@2022-09-01' = {
  name: vpnSiteName
  location: location
  properties: {
     addressSpace: {
      addressPrefixes: vpnsiteAddressPrefixes
    } 
    
    virtualWan: {
      id: vwan.id
    }
    
    vpnSiteLinks: [
      {
        name: 'link1'
        properties: {
          linkProperties: {
            linkProviderName: 'linkprovider'
            linkSpeedInMbps: 100
          }
          ipAddress: link1vpnsiteIPAddress
          bgpProperties: (enableBGP ? {
            asn: vpnsiteASN
            bgpPeeringAddress: link1bgpPeeringAddress
          } : null)
        }
      }
      {
        name: 'link2'
        properties: {
          linkProperties: {
            linkProviderName: 'linkprovider'
            linkSpeedInMbps: 100
          }
          ipAddress: link2vpnsiteIPAddress
          bgpProperties: (enableBGP ? {
            asn: vpnsiteASN
            bgpPeeringAddress: link2bgpPeeringAddress
          } : null)
        }
      }
    ] 
  }
} 

// connect site to hub gateway
resource vpnConnection 'Microsoft.Network/vpnGateways/vpnConnections@2022-07-01' = {
  parent: gateway
  name: 'vpnconnection2'
  properties: {
    remoteVpnSite: {
      id: vpnSite.id
    }
    vpnLinkConnections: [
      {
        name: 'link1'
        properties: {
          vpnSiteLink: {
            id: vpnSite.properties.vpnSiteLinks[0].id
          }
          vpnConnectionProtocolType: 'IKEv2'
          connectionBandwidth: 100
          sharedKey: link1sharedkey
          usePolicyBasedTrafficSelectors: false
          enableBgp: enableBGP
          ipsecPolicies: [
            {
                saLifeTimeSeconds: 28800
                saDataSizeKilobytes: 102400
                ipsecEncryption: 'AES256'
                ipsecIntegrity: 'SHA256'
                ikeEncryption: 'GCMAES256'
                ikeIntegrity: 'SHA256'
                dhGroup: 'DHGroup14'
                pfsGroup: 'PFS14'
            }
          ]
        }
      }
      {
        name: 'link2'
        properties: {
          vpnSiteLink: {
            id: vpnSite.properties.vpnSiteLinks[1].id
          }
          vpnConnectionProtocolType: 'IKEv2'
          connectionBandwidth: 100
          sharedKey: link2sharedkey
          usePolicyBasedTrafficSelectors: false
          enableBgp: enableBGP
          ipsecPolicies: [
            {
                saLifeTimeSeconds: 28800
                saDataSizeKilobytes: 102400
                ipsecEncryption: 'AES256'
                ipsecIntegrity: 'SHA256'
                ikeEncryption: 'GCMAES256'
                ikeIntegrity: 'SHA256'
                dhGroup: 'DHGroup14'
                pfsGroup: 'PFS14'
            }
          ]
        }
      }
    ]

  }


}
