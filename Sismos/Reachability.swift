//
//  Reachability.swift
//  Sismos
//
//  Created by MacBook Pro on 8/15/18.
//  Copyright © 2018 Iree García. All rights reserved.
//

import SystemConfiguration

public class Reachability {
   public static func isConnectedToNetwork() -> Bool {
      var zeroAddress = sockaddr_in()
      zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
      zeroAddress.sin_family = sa_family_t(AF_INET)
      
      guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
         $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
         }
      }) else {
         return false
      }
      
      var flags: SCNetworkReachabilityFlags = []
      if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
         return false
      }
      
      let isReachable = flags.contains(.reachable)
      let needsConnection = flags.contains(.connectionRequired)
      
      return (isReachable && !needsConnection)
   }
}
