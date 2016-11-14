from pyspark import SparkConf, SparkContext
from pyspark.sql import HiveContext
sc = SparkContext()
sqlContext = HiveContext(sc)

user_df = sqlContext.read.parquet("/training/data/user.parquet")
user_df.registerTempTable("user")

count_by_gender = sqlContext.sql("select gender, count(*) as cnt from user group by gender order by cnt desc")
count_by_gender.show()

track_df = sqlContext.sql("SELECT * FROM default.track")
track_df.limit(5).show()

