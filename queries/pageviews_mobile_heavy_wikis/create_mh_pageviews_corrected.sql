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


CREATE EXTERNAL TABLE IF NOT EXISTS mneisler.mh_pageviews_corrected (  
	`date` string,
	`all_views` bigint ,
	`mh_views` bigint 
) 
PARTITIONED BY (year int, month int, day int)

STORED AS PARQUET;
