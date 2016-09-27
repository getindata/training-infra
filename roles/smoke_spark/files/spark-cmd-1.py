from pyspark import SparkConf, SparkContext
from pyspark.sql import HiveContext
sc = SparkContext()
sqlContext = HiveContext(sc)


logs = sqlContext.sql("SELECT * FROM lion.logs")
logs.limit(3).show()
streams_raw = logs.filter(logs['eventType'] == 'SongPlayed')
streams_projected = streams_raw.drop('eventType')
streams = streams_projected.withColumnRenamed('itemId', 'trackId')
streams.limit(3).show()


