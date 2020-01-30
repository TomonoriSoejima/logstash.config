### Suppose you have a documbent below.

```
hostname　：　host1
id.1　：　1 
id.2　：　2 
id.3　：　3
ifDescr.101 :  eth1
ifDescr.102 :  eth2
ifDescr.103 :  eth3
```

###  Then you desire to produce 3 documents.

```
1) 
hostname : hostname 
id : 1
ifDescr : eth2 

2) 
hostname : hostname 
id : 2 
ifDescr : eth2 

3) 
hostname : hostname 
id : 3
ifDescr : eth3
```

**Verdict**
You need a split filter plugin and [elasticsearch output plugin](https://www.elastic.co/guide/en/logstash/6.6/plugins-outputs-elasticsearch.html#plugins-outputs-elasticsearch-document_id) working together.
`split filter plugin` alone is not enough.

**Details**

**1.**  You need to think about data structure and in this example, we are using an array.
```
{
  "hostname": "soejima",
  "cards": [
    {
      "id": "1",
      "ifDescr": "eth1"
    },
    {
      "id": "2",
      "ifDescr": "eth2"
    },
    {
      "id": "3",
      "ifDescr": "eth3"
    }
  ]
}
```

Note that when you will get these errors  "_http_request_failure", "_split_type_failure" if the input is pretty-printed, so the entry should be a single line as below.

`
{"hostname":"soejima", "cards" : [{"id" : "1", "ifDescr" : "eth1" }, {"id" : "2" , "ifDescr" : "eth2"}, {"id" : "3", "ifDescr" : "eth3"}]}`

**2.** split the document accordingly and assign the resulting data to `document_id` in `elasticsearch output plugin`


```
input {
    http_poller {
        urls => {
            test => "https://gist.githubusercontent.com/TomonoriSoejima/5a1aea31ba808c35de14acacb2f6d084/raw/07e63d207ae01b091fae38f90a92f8b9671abed9/test"
        }
        schedule => { every => "10s"}
        codec => "json"
    }
}

filter {
    split { field => "cards"}
    split { field => "[cards][id]"}
}

output {
    elasticsearch {
        hosts => "localhost:9200"
        document_id => "%{[cards][id]}"
    }
}
```
**3.** Now you get 3 documents in return.

```
[wave:curls]$ curl -s -GET "http://localhost:9200/logstash-2019.03.20/_search" | jq .hits.hits
[
  {
    "_index": "logstash-2019.03.20",
    "_type": "doc",
    "_id": "2",
    "_score": 1,
    "_source": {
      "cards": {
        "id": "2",
        "ifDescr": "eth2"
      },
      "@timestamp": "2019-03-20T03:23:40.498Z",
      "@version": "1",
      "hostname": "soejima"
    }
  },
  {
    "_index": "logstash-2019.03.20",
    "_type": "doc",
    "_id": "1",
    "_score": 1,
    "_source": {
      "cards": {
        "id": "1",
        "ifDescr": "eth1"
      },
      "@timestamp": "2019-03-20T03:23:40.498Z",
      "@version": "1",
      "hostname": "soejima"
    }
  },
  {
    "_index": "logstash-2019.03.20",
    "_type": "doc",
    "_id": "3",
    "_score": 1,
    "_source": {
      "cards": {
        "id": "3",
        "ifDescr": "eth3"
      },
      "@timestamp": "2019-03-20T03:23:40.498Z",
      "@version": "1",
      "hostname": "soejima"
    }
  }
]
```


