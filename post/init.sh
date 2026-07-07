#!/bin/sh
# Same as taubyte/workshops — copy vendored binaries, nothing else.
cd post && \
sudo cp tau dream /bin/ && \
sudo chmod 755 /bin/tau /bin/dream && \
echo 'eval "$(tau autocomplete)"' >> ~/.bashrc
