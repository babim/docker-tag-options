# Install Elastic Stack
(C) AQ.jsc Viet Nam (https://matmagoc.com)

## install depend
`apt-get wget bash -y`

## install elasticsearch
`wget -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/elasticsearch_install.sh | bash`

## install kibana
`wget -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/kibana_install.sh | bash`

## install logstash
`wget -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/logstash_install.sh | bash`

## install elasticstack
`wget -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/stack_install.sh | bash`

## Set version
```
ENV ES_VERSION 1.7 #elasticsearch
ENV KB_VERSION 6.3.0 #kibana
ENV LS_VERSION 6.3.0 #logstash
ENV STACK_NEW true #elasticstack
	if [[ "$STACK_NEW" == "true" ]]; then
		ES_VERSION=$STACK
		LS_VERSION=$STACK
		KB_VERSION=$STACK
	fi
```
