from pyspark import SparkConf, SparkContext
from pyspark.sql import HiveContext
sc = SparkContext()
sqlContext = HiveContext(sc)

user_df = sqlContext.read.parquet("/training/data/user.parquet")
user_df.show()

user_df.printSchema()

user_df.select("fname").distinct().show()
user_df.select("fname").distinct().count()
user_df.groupBy("fname").count().filter("count > 1").show()
user_df.select("fname").take(1)

user_df_cached = user_df.cache()

user_df_cached.select("fname").take(1)
user_df_cached.select("fname").take(1)

user_df_cached.groupBy("state").count().show()
user_df_cached.groupBy("state").count().filter("count > 50").show()
user_df_cached.groupBy("state").count().orderBy("count").show()

from pyspark.sql.functions import *
user_df_cached.groupBy("state").count().orderBy(desc("count")).show()
user_df_cached.groupBy("state", "gender").count().orderBy(["state", "gender"], ascending=[0, 1]).show()
user_df_cached.groupBy("state").agg({"birthdate" : "min"}).show()

from pyspark.sql import functions as F
user_df_cached.groupBy("state").agg(F.min(user_df_cached.birthdate)).show()
