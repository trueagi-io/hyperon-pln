FROM trueagi/hyperon

ENV HOME=/home/user
WORKDIR ${HOME}

RUN git clone https://github.com/trueagi-io/hyperon-pln.git
WORKDIR ${HOME}/hyperon-pln
