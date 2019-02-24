# Atlassian JIRA Core in a Docker container
## (Thanks Martin Aksel Jensen cptactionhank)

## Get me started

To quickly get started running a JIRA Core instance, use the following command:
```bash
docker run --detach --publish 8080:8080 babim/jira-core
docker run --detach --publish 8080:8080 babim/jira-software
docker run --detach --publish 8080:8080 babim/jira-servicedesk
```
```
volume:
/var/atlassian/jira
/opt/atlassian/jira
```

Then simply navigate your preferred browser to `http://[dockerhost]:8080` and finish the configuration.

## Configuration

You can configure a small set of things by supplying the following environment variables

| Environment Variable   | Description |
| ---------------------- | ----------- |
| X_PROXY_NAME           | Sets the Tomcat Connectors `ProxyName` attribute |
| X_PROXY_PORT           | Sets the Tomcat Connectors `ProxyPort` attribute |
| X_PROXY_SCHEME         | If set to `https` the Tomcat Connectors `secure=true` and `redirectPort` equal to `X_PROXY_PORT`   |
| X_PATH                 | Sets the Tomcat connectors `path` attribute |
