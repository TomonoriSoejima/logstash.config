# echo test for SIGHUP
# date +%Y-%m-%dT%H:%M:%S

# sudo kill -SIGHUP $(pgrep logstash | grep -v sudo | awk '{print $1}')
# # sudo /bin/kill -SIGHUP 80245


# tail -5 ../logstash-7.15.2/logs/logstash-plain.log 


config="/Users/surfer/elastic/labs/logstash/logstash.config/translate.filter.conf"

echo test for --config.reload.automatic 
#perl -i -pe s/google/apple/ $config
perl -i -pe s/apple/google/ $config
sleep 2
tail -5 ../logstash-7.15.2/logs/logstash-plain.log 
