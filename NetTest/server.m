//
//  server.c
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
#include "prefix.h"


int udpServer()
{
    struct sockaddr_in s_addr;
    struct sockaddr_in c_addr;
    int sock;
    socklen_t addr_len;
    int len;
    char buff[128];
    
    if( (sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1)
    {
        perror("socket");
        exit(errno);
    }
    else
    {
        printf("create send socket \n\r");
    }
    memset(&s_addr, 0, sizeof(struct sockaddr_in));
    s_addr.sin_family = AF_INET;
    s_addr.sin_port = htons(PORT);
    s_addr.sin_addr.s_addr = INADDR_ANY;
    if ((bind(sock, (struct sockaddr*)&s_addr, sizeof(s_addr))) == -1)
    {
        perror("bind");
        exit(errno);
    }
    printf("bind address to socket\n\r");
    addr_len = sizeof(c_addr);
    
    while (1)
    {
        len = recvfrom(sock, buff, sizeof(buff)-1, 0, (struct sockaddr *)&c_addr, &addr_len);
        if (len < 0) {
            perror("recvfrom");
            exit(errno);
        }
        buff[len] = '\0';
        printf("recive come from %s:%d message:%s\n\r", inet_ntoa(c_addr.sin_addr), ntohs(c_addr.sin_port), buff);
    }
    
    
    return 0;
}


int tcpserver()
{
    int sockfd, new_fd;
    socklen_t len;
    struct sockaddr_in my_addr, theri_addr;
    unsigned int myport, lisnum;
    char buf[MAXBUF+1];
    myport = PORT;
    lisnum = 5;
    
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
    {
        perror("socket");
        exit(errno);
    }
    
    bzero(&my_addr, sizeof(my_addr));
    my_addr.sin_family = AF_INET;
    my_addr.sin_port = htons(myport);
//    char *ip = "192.168.33.237";
//    ip = "127.0.0.1";
//    my_addr.sin_addr.s_addr = inet_addr(ip);
    my_addr.sin_addr.s_addr = INADDR_ANY;
    
    if (bind(sockfd, (struct sockaddr *)&my_addr, sizeof(struct sockaddr)) == -1)
    {
        perror("bind");
        exit(errno);
    }
    if (listen(sockfd, lisnum) == -1)
    {
        perror("listen");
        exit(errno);
    }
    printf("wait for connect\n");
    len = sizeof(struct sockaddr);
    if ( (new_fd = accept(sockfd, (struct sockaddr*)&theri_addr, &len)) == -1)
    {
        perror("accept");
        exit(errno);
    }
    printf("server: got connection from: %s, port:%d, socket:%d\n", inet_ntoa(theri_addr.sin_addr), ntohs(theri_addr.sin_port), new_fd);
    
    while (1)
    {
        printf("newfd = %d\n", new_fd);
        bzero(buf, MAXBUF+1);
        printf("input the message to send:\n");
        fgets(buf, MAXBUF, stdin);
        if (!strncasecmp(buf, "quit", 4))
        {
            printf("quit!!!!!\n");
            break;
        }
        len = send(new_fd, buf, strlen(buf)-1, 0);
        if (len > 0)
        {
            printf("message:%s\t send successful, send %dbytes\n", buf, len);
        }
        else
        {
            printf("send failed!!!\n");
        }
        bzero(buf, MAXBUF+1);
        
        len = recv(new_fd, buf, MAXBUF, 0);
        if (len > 0)
        {
            printf("message recv successful: %s %dbyte\n", buf, len);
        }
        else
        {
            if (len < 0) {
                printf("recv failure errno code is %d, errno message is:%s\n", errno, strerror(errno));
            }
            else
            {
                printf("the other one close quit\n");
            }
            break;
        }
    }
    
    close(new_fd);
    close(sockfd);
    
    return 0;
}


int main(int argc, const char * argv[])
{
    printf("server\n");
#if USE_UDP
    return udpServer();
#else
    return tcpserver();
#endif
    
    return 0;
}



