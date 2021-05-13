FROM verificarlo/fuzzy as fuzzy

FROM fcpindi/c-pac:nightly

# Copy libmath fuzzy environment from fuzzy image
COPY --from=fuzzy /opt/mca-libmath/* /opt/mca-libmath/
COPY --from=fuzzy /opt/vfc-backends.txt /opt/
COPY --from=fuzzy /usr/local/bin/verificarlo* /usr/local/bin/
COPY --from=fuzzy /usr/local/include/vfcwrapper.c /usr/local/include/
COPY --from=fuzzy /usr/local/lib/libinterflop* /usr/local/lib/

ENV LIB_WRAP=/opt/mca-libmath/libmath.so
ENV LD_PRELOAD="${LIB_WRAP}"
ENV VFC_BACKENDS_FROM_FILE=/opt/vfc-backends.txt
