FROM rocker/hadleyverse
MAINTAINER Marc A. Suchard <msuchard@ucla.edu>

## Install Rserve
RUN install2.r \
	Rserve \
	RSclient \
	openssl \
	httr \
&& rm -rf /tmp/download_packages/ /tmp/*.rds

## Install OHDSI R packages
RUN installGithub.r \
	OHDSI/SqlRender \
	OHDSI/DatabaseConnector \
	OHDSI/Cyclops \
	OHDSI/OhdsiRTools \
	cloudyr/aws.s3 \
	OHDSI/OhdsiSharing \
	OHDSI/FeatureExtraction \
	OHDSI/PatientLevelPrediction \
	OHDSI/CohortMethod \
	OHDSI/PublicOracle \
	OHDSI/StudyProtocols/KeppraAngioedema \
&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds


COPY Rserv.conf /etc/Rserv.conf
COPY startRserve.R /usr/local/bin/startRserve.R

EXPOSE 6311

RUN apt-get update && apt-get install -y supervisor

RUN echo "" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "[program:Rserve]" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "command=/usr/local/bin/startRserve.R" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "stdout_logfile=/var/log/supervisor/%(program_name)s.log" >> /etc/supervisor/conf.d/supervisord.conf \
	&& echo "stderr_logfile=/var/log/supervisor/%(program_name)s.log" >> /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

