FROM amazon/aws-cli:2.0.6

# MySQLクライアント＋αをインストール
RUN rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm \
    && yum install -y mysql-community-client.x86_64 gzip \
    && yum clean all \
    && rm -rf /var/cache/yum

COPY backup.sh /backup.sh

ENTRYPOINT []
CMD ["/backup.sh"]
