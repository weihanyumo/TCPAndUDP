//
//  client.m
//  NetTest
//
//  Created by duhaodong on 16/8/24.
//  Copyright © 2016年 duhaodong. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <errno.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <net/if_arp.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include "prefix.h"


void GetLocalIp(char *ip)
{
    return;
    int sock_get_ip;
    char ipaddr[50];
    
    struct   sockaddr_in *sin;
    struct   ifreq ifr_ip;
    
    if ((sock_get_ip=socket(AF_INET, SOCK_STREAM, 0)) == -1)
    {
        printf("socket create failse...GetLocalIp!/n");
    }
    
    memset(&ifr_ip, 0, sizeof(ifr_ip));
    strncpy(ifr_ip.ifr_name, "eth0", sizeof(ifr_ip.ifr_name) - 1);
    
    if( ioctl( sock_get_ip, SIOCGIFADDR, &ifr_ip) < 0 )
    {
    }
    sin = (struct sockaddr_in *)&ifr_ip.ifr_addr;
    strcpy(ipaddr,inet_ntoa(sin->sin_addr));
    
    printf("local ip:%s /n",ipaddr);
    close( sock_get_ip );
    
    memcmp(ip,ipaddr, strlen(ipaddr));
}


int UDPSendMessage()
{
    struct sockaddr_in s_addr;
    int sock;
    int addr_len;
    int len;
    char buf[128];
    if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1)
    {
        perror("socket");
        exit(errno);
    }
    printf("created client socket sucess\n");
    s_addr.sin_family = AF_INET;
    s_addr.sin_port = PORT;
    char ip[128];
    memset(ip, 0, sizeof(ip));
    GetLocalIp(ip);
    
    s_addr.sin_addr.s_addr = inet_addr("192.168.33.237");
    addr_len = sizeof(s_addr);
    
    strcpy(buf, "hello i am here");
    len = sendto(sock, buf, strlen(buf), 0, (struct sockaddr *)&s_addr, addr_len);
    if (len < 0) {
        printf("\n\r send error");
        return 3;
    }
    printf("send message success\n");
    return 0;
}



int TCPSendMessage()
{
    int sockfd, len;
    struct sockaddr_in dest;
    char buf[MAXBUF + 1];
    
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
    {
        perror("Socket");
        exit(errno);
    }
    
    printf("socket created\n");
    
    bzero(&dest, sizeof(dest));
    dest.sin_family = AF_INET;
    dest.sin_port = htons(PORT);
    char *ip = "192.168.33.237";
//    ip = "127.0.0.1";
    if (inet_aton(ip, (struct in_addr *)&dest.sin_addr.s_addr) == 0)
    {
        perror("ip");
        exit(errno);
    }
    if (connect(sockfd, (struct sockaddr *)&dest, sizeof(dest)) == -1)
    {
        perror("Connect");
        exit(errno);
    }
    
    printf("server connected\n");
    
    while (1)
    {
        bzero(buf, MAXBUF+1);
        len = recv(sockfd, buf, MAXBUF, 0);
        if (len > 0)
        {
            printf("recv successful:%s, %d\n", buf, len);
        }
        else
        {
            if (len < 0) {
                printf("send failure, errno code is:%d, err message is:%s", errno, strerror(errno) );
            }
            else
            {
                printf("the other close, quit\n");
            }
            break;
        }
        bzero(buf, MAXBUF + 1);
        printf("please send message to send:\n");
        fgets(buf, MAXBUF, stdin);
        if (!strncasecmp(buf, "quit", 4)) {
            printf("i will quti \n");
            break;
        }
        len = send(sockfd, buf, strlen(buf)-1, 0);
        if (len < 0) {
            printf("message:%s send failure\n");
        }
        else
        {
            printf("message:%s\tsend successful, %dbyte send!\n",buf, len);
        }
        bzero(buf, MAXBUF+1);
        
    }
    
    close(sockfd);
    
    return 0;
}

int main(int argc, const char * argv[]) {
    printf("client\n");
#if USE_UDP
    return UDPSendMessage();
#else
    return TCPSendMessage();
#endif
    
    return 0;
}



