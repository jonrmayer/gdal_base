FROM jonrmayer/gdal_alpine:latest as builder

RUN yum -y install wget make unzip curl

RUN \
    mkdir -p /build_projgrids/usr/share/proj \
    && curl -LOs http://download.osgeo.org/proj/proj-datumgrid-latest.zip \
    && unzip -q -j -u -o proj-datumgrid-latest.zip  -d /build_projgrids/usr/share/proj \
    && rm -f *.zip

RUN mkdir proj \
    && wget https://download.osgeo.org/proj/proj-5.2.0.tar.gz	\
	&& tar -zvxf proj-5.2.0.tar.gz \
    && cd proj-5.2.0 \
	&&  ./configure --prefix=/usr \
	&& make -j 16 \
    && make install \
	&& make install DESTDIR="/build_proj"
	
RUN wget http://download.osgeo.org/gdal/2.3.0/gdal-2.3.0.tar.gz \
&& tar -zvxf gdal-2.3.0.tar.gz 

RUN  cd gdal-2.3.0 \
&& ./configure --with-proj=/usr --with-threads --with-libtiff=internal --with-geotiff=internal --with-jpeg=internal --with-gif=internal --with-png=internal --with-libz=internal \
&& make \
&& make install \
&& make install DESTDIR="/build"
	


FROM jonrmayer/gdal_alpine:latest as runner

COPY --from=builder  /build_projgrids/usr/  /gdal/build_projgrids/usr/share/proj/

COPY --from=builder  /build_proj/usr/share/proj/ /gdal/build_proj/usr/share/proj/
COPY --from=builder  /build_proj/usr/include/ /gdal/build_proj/usr/include/
COPY --from=builder  /build_proj/usr/bin/ /gdal/build_proj/usr/bin/
COPY --from=builder  /build_proj/usr/lib/ /gdal/build_proj/usr/lib/

COPY --from=builder  /build/usr/local/share/gdal/ /gdal/usr/share/gdal/
COPY --from=builder  /build/usr/local/include/ /gdal/usr/include/
