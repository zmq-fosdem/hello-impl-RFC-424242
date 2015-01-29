all: out/server out/client

out/%: %.c
	@[ -d out ] || mkdir out
	gcc -lczmq -lzmq $< -o $@

.PHONY: all
