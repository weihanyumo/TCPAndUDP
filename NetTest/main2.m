//
//  main.m
//  NetTest
//
//  Created by duhaodong on 16/8/23.
//  Copyright © 2016年 duhaodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <netdb.h>

void ToAddrV4(const struct sockaddr_in6 *addr6, struct sockaddr_in *addr4)
{
    memset(addr4, 0, sizeof(struct sockaddr_in));
    addr4->sin_family = AF_INET;
    addr4->sin_len = sizeof(struct sockaddr_in);
    addr4->sin_port = addr6->sin6_port;
    
    uint8_t field1 = addr6->sin6_addr.__u6_addr.__u6_addr8[15];
    uint8_t field2 = addr6->sin6_addr.__u6_addr.__u6_addr8[14];
    uint8_t field3 = addr6->sin6_addr.__u6_addr.__u6_addr8[13];
    uint8_t field4 = addr6->sin6_addr.__u6_addr.__u6_addr8[12];
    
    __uint32_t addr_int = (field1 << 24) | (field2 << 16) | (field3 << 8) | field4;
    
    //printf("%d.%d.%d.%d,%u\n",field4,field3,field2,field1,addr_int);
    
    addr4->sin_addr.s_addr = addr_int;
}
int NTGetAddrInfo(char *HostName)
{
    struct sockaddr_in Addr;
    struct addrinfo hints, *res, *res0;
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family   = PF_UNSPEC;
    //hints.ai_socktype = SOCK_DGRAM;//SOCK_STREAM
    //hints.ai_protocol = IPPROTO_UDP;//IPPROTO_TCP
    hints.ai_flags = AI_DEFAULT;//AI_NUMERICHOST;
    
    if(getaddrinfo(HostName, NULL, &hints, &res0) == 0)
    {
        for(res = res0; res; res = res->ai_next)
        {
            if(res->ai_family == AF_INET)
            {
                memcpy(&(Addr.sin_addr), &(((struct sockaddr_in *)(res->ai_addr))->sin_addr), sizeof(struct in_addr));
                break;
            }
            else if(res->ai_family == AF_INET6)
            {
                // Found IPv6 address
                struct sockaddr_in6 Addr6;
                memset(&Addr6, 0, sizeof(struct sockaddr_in6));
                //Addr6.sin6_len = sizeof(struct sockaddr_in6);
                Addr6.sin6_family = AF_INET6;
                Addr6.sin6_port = Addr.sin_port;
                memcpy(&(Addr6.sin6_addr), &(((struct sockaddr_in6 *)(res->ai_addr))->sin6_addr), sizeof(struct in6_addr));
                ToAddrV4(&Addr6, &Addr);
                break;
            }
        }
        freeaddrinfo(res0);
    }

    return 0;
}
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        char *hostName = "www.baidu.com";
        NTGetAddrInfo(hostName);
        NSLog(@"Hello, World!");
    }
    return 0;
}

