FROM verificarlo/fuzzy as fuzzy

FROM fcpindi/c-pac:nightly

# Copy libmath fuzzy environment from fuzzy image
# RUN mkdir -p /opt/mca-libmath
COPY --from=fuzzy /opt/mca-libmath/* /opt/mca-libmath/
COPY --from=fuzzy /usr/local/bin/verificarlo* /usr/local/bin/
COPY --from=fuzzy /usr/local/lib/libinterflop* /usr/local/lib/

RUN export LD_PRELOAD=/opt/mca-libmath/libmath.so

ENV VFC_BACKENDS_FROM_FILE=/opt/vfc-backends.txt
ENV VFC_BACKENDS 'libinterflop_mca.so --precision-binary32=24 --precision-binary64=53 --mode=mca'
