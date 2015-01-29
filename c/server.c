#include <assert.h>
#include <czmq.h>


int main(int argc, char **argv) {    

    assert (argv[1]);
    zsock_t *server = zsock_new (ZMQ_REP);
    assert (server);
    //int rv = zsock_bind (server, "tcp://*:6666");
    int rv = zsock_bind (server, argv[1]);

    while (1) {
        char *string = zstr_recv (server);        
        if (strcmp (string, "Hello") == 0) {
            puts ("Got Hello\n");
            zstr_send (server, "Hello World");
        } else {
            puts ("Got rubbish!\n");
            zstr_send (server, "Error");
        }
        zstr_free(&string);
    }

    zsock_destroy (&server);
    assert (server == NULL);
    return 0;
}
