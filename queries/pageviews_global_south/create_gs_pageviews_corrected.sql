SET hive.mapred.mode='nonstrict';
SET hive.exec.dynamic.partition = 'true';
SET hive.exec.dynamic.partition.mode = 'nonstrict';
SET hive.exec.max.dynamic.partitions = 2000;
SET hive.exec.max.dynamic.partitions.pernode = 1000;
SET mapred.job.queue.name=nice;

SET parquet.compression              = SNAPPY;
SET mapred.reduce.tasks              = 16;

SET hive.exec.compress.output=true;
SET mapreduce.output.fileoutputformat.compress.codec=org.apache.hadoop.io.compress.GzipCodec;


CREATE EXTERNAL TABLE IF NOT EXISTS mneisler.gs_pageviews_corrected (  
	`date` string,
	`region` string ,
	`pageviews` bigint 
) 
PARTITIONED BY (year int, month int, day int)

STORED AS PARQUET;
