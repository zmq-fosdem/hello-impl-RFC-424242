#include <czmq.h>
#include <unistd.h>

#define request "Hello, I'm whatever"
#define reply "Hello World"

int main (int argc, char** argv)
{
    int i;
    char buff[655360];
    strcpy(buff, "tcp://192.168.1.1:6665");
    for(i = 2; i<255; i++) {
        char tmp[128];
        sprintf(tmp, ",tcp://192.168.1.%d:6665", i);
        strcat(buff,tmp);
    }
    zsock_t *sub = zsock_new_sub (buff, "");
    zrex_t* rex = zrex_new("");
    while(!zsys_interrupted) {
        char *string = zstr_recv (sub);
        if((string == NULL))
            continue;
        sprintf(buff, "tcp://192.168.1.%s", string);
        zstr_free (&string);
        printf("Got '%s'\n", buff);
        zsock_t *req = zsock_new_dealer (buff);
        if(req == NULL)
            continue;

        zsock_set_rcvtimeo (req, 100);
        zstr_send (req, request);
        string = zstr_recv(req);
        if(string != NULL)
            printf("Received '%s'!\n", string);

        zstr_free (&string);
        zsock_destroy (&req);
    }
    zsock_destroy (&sub);
    return 0;

}
