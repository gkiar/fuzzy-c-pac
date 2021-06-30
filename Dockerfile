FROM fcpindi/c-pac:latest

# Copy libmath fuzzy environment from fuzzy image
COPY --from=verificarlo/fuzzy:v0.5.0-lapack /opt/mca-libmath/* /opt/mca-libmath/
COPY --from=verificarlo/fuzzy:v0.5.0-lapack /opt/vfc-backends.txt /opt/
COPY --from=verificarlo/fuzzy:v0.5.0-lapack /usr/local/bin/verificarlo* /usr/local/bin/
COPY --from=verificarlo/fuzzy:v0.5.0-lapack /usr/local/include/vfcwrapper.c /usr/local/include/
COPY --from=verificarlo/fuzzy:v0.5.0-lapack /usr/local/lib/libinterflop* /usr/local/lib/

ENV LIB_WRAP=/opt/mca-libmath/libmath.so
ENV LD_PRELOAD="${LIB_WRAP}"
ENV VFC_BACKENDS_FROM_FILE=/opt/vfc-backends.txt

