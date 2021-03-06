# The MIT License (MIT)
#
# Copyright (c) 2017
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM nginx:alpine

# Install dependencies
RUN apk add --no-cache python python-dev openssl-dev gcc musl-dev git && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    rm -r /root/.cache

# copy nginx config over
COPY nginx/* /etc/nginx/conf.d/
RUN rm /etc/nginx/conf.d/default.conf

# Install the proxy script
COPY coinhive-stratum-mining-proxy.py /coinhive-stratum-mining-proxy.py

# Install static and template files
ADD static/miner/cryptonight-asmjs.min.js.mem /static/miner/cryptonight-asmjs.min.js.mem
ADD static/miner/cryptonight.wasm /static/miner/cryptonight.wasm
COPY templates /templates

# Install Python dependencies
COPY requirements.txt /requirements.txt
RUN pip install -v -r /requirements.txt && rm /requirements.txt

# Expose HTTP/WebSocket port
EXPOSE 80

# Set env vars
ENV STRATUM_POOL=pool.supportxmr.com
ENV STRATUM_PORT=2999
ENV STRATUM_PASS=TEST1:mikejackofalltrades@gmail.com

# Launch the service
CMD [nginx-debug, '-g', 'daemon off;']
ENTRYPOINT /coinhive-stratum-mining-proxy.py $STRATUM_POOL $STRATUM_PORT $STRATUM_PASS
# CMD python coinhive-stratum-mining-proxy.py $STRATUM_POOL $STRATUM_PORT $STRATUM_PASS
