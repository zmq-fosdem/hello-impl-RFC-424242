#include <czmq.h>
#include <unistd.h>

#define request "Hello"
#define reply "Hello World"

int main (int argc, char** argv)
{
    int i;
    for(i = 1; i<255 && !zsys_interrupted; i++) {
        char buff[128];
        sprintf(buff, "tcp://192.168.1.%d:6666", i);
        zsock_t *req = zsock_new_req (buff);
        zsock_set_rcvtimeo(req, 100);

        zstr_send (req, request);
        char *string = zstr_recv (req);
        if(string != NULL)
            printf("Received '%s' from 192.168.1.%d!\n", string, i);

        zstr_free (&string);
        zsock_destroy (&req);
    }
    return 0;

}
