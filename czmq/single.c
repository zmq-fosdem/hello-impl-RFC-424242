#include <czmq.h>

int main (void)
{
    zsock_t *pub = zsock_new_pub ("tcp://*:6665");
    
    zsock_t *router = zsock_new_router ("tcp://*:*");
    char *endpoint = zsock_endpoint (router);
    assert (endpoint);

    zsock_t *sub = zsock_new (ZMQ_SUB);
    zsock_set_subscribe (sub, "");
    int address;
    for (address = 2; address < 255; address++) {
        int rc = zsock_connect (sub, "tcp://192.168.1.%d:6665", address);
        assert (rc == 0);
    }
    
    zpoller_t *poller = zpoller_new (router, sub, NULL);
    while (!zsys_interrupted) {
        zsock_t *which = zpoller_wait (poller, 1000);
        if (which == router) {
            zframe_t *routing_id = zframe_recv (router);
            zmsg_t *request = zmsg_recv (router);
            zmsg_print (request);
            zframe_send (&routing_id, router, ZFRAME_MORE);
            zstr_send (router, "Pieter");
        }
        else
        if (which == sub) {
            char *address = zstr_recv (sub);
            printf ("SUB: <%s>", address);
            if (isdigit (*address)) {
                zsock_t *dealer = zsock_new (ZMQ_DEALER);
                zsock_connect (dealer, "tcp://192.168.1.%s", address);
                zsock_set_rcvtimeo (dealer, 5000);
                zstr_send (dealer, "Hello (from Pieter)");
                char *reply = zstr_recv (dealer);
                if (reply)
                    puts (reply);
                zsock_destroy (&dealer);
            }
        }
        else
            zstr_sendf (pub, "232%s", endpoint + 7);
    }
    zsock_destroy (&sub);
    zsock_destroy (&pub);
    zsock_destroy (&router);
    return 0;
}