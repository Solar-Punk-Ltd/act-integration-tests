FROM python:slim

ARG P_KEY
ARG RPC_URL

COPY scripts/* .
RUN chmod 700 *.sh

RUN pip3 install web3cli
RUN ./w3_init.sh $P_KEY $RPC_URL

ENV T0_ADDRESS=0x

ENTRYPOINT ./start.sh $T0_ADDRESS